#!/usr/bin/env bash

set -euo pipefail

declare -A testCases=(
    [complete_values]="--values test-values.yaml"
    [env_from]="--values test-values-with-env.yaml"
    [nodeport]="--values test-values.yaml --values test-https.yaml --values test-nodeport.yaml"
    [https]="--values test-values.yaml --values test-https.yaml"
)

declare -A testCaseCharts=(
    [complete_values]="../../charts/gateway"
    [env_from]="../../charts/gateway"
    [nodeport]="../../charts/gateway"
    [https]="../../charts/gateway"
)

TEST_NAMES=(complete_values env_from nodeport https)

function join_by {
    local d=${1-} f=${2-}
    if shift 2; then
        printf %s "$f" "${@/#/$d}"
    fi
}

# default to randomly generated namespace, same as chart-testing would do, but we need to load secrets into the same namespace
NAMESPACE=trino-gateway-$(LC_ALL=C tr -dc 'a-z0-9' </dev/urandom | head -c 6 || true)
DB_NAMESPACE=postgres-gateway
kubectl create namespace "${NAMESPACE}" --dry-run=client --output yaml | kubectl apply --filename -
kubectl create namespace "${DB_NAMESPACE}" --dry-run=client --output yaml | kubectl apply --filename -

# install the Prometheus Helm chart when running the `complete_values` test
if printf '%s\0' "${TEST_NAMES[@]}" | grep -qwz complete_values; then
    helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
    helm upgrade --install prometheus-operator prometheus-community/kube-prometheus-stack -n "$NAMESPACE" \
        --version "68.2.1" \
        --set prometheus.prometheusSpec.serviceMonitorSelectorNilUsesHelmValues=false \
        --set prometheus.prometheusSpec.serviceMonitorSelector.matchLabels.prometheus=default \
        --set grafana.enabled=false \
        --set alertmanager.enabled=false \
        --set kubeApiServer.enabled=false \
        --set kubelet.enabled=false \
        --set kubeControllerManager.enabled=false \
        --set coreDns.enabled=false \
        --set kubeEtcd.enabled=false \
        --set kubeScheduler.enabled=false \
        --set kubeProxy.enabled=false \
        --set kubeStateMetrics.enabled=false \
        --set nodeExporter.enabled=false \
        --set prometheusOperator.admissionWebhooks.enabled=false \
        --set prometheusOperator.kubeletService.enabled=false \
        --set prometheusOperator.tls.enabled=false \
        --set prometheusOperator.serviceMonitor.selfMonitor=false \
        --set prometheus.serviceMonitor.selfMonitor=false
    kubectl rollout status --watch deployments -l release=prometheus-operator -n "$NAMESPACE"
    # Wait for Prometheus pod to be ready and give it time to discover ServiceMonitors
    echo 1>&2 "Waiting for Prometheus to be ready..."
    kubectl wait --for=condition=ready pod -l app.kubernetes.io/name=prometheus -n "$NAMESPACE" --timeout=300s || true
    # Give Prometheus Operator time to reconcile and discover ServiceMonitors
    echo 1>&2 "Waiting for Prometheus to discover ServiceMonitors..."
    sleep 10
fi

echo 1>&2 "Generating a self-signed TLS certificate"
NODE_IP=$(kubectl get nodes -o json  -o jsonpath='{.items[0].status.addresses[0].address}')
openssl req -new -newkey rsa:4096 -days 365 -nodes -x509 \
    -subj "/O=Trino Software Foundation" \
    -addext "subjectAltName=DNS:trino-gateway,DNS:localhost,DNS:*.$NAMESPACE,DNS:*.$NAMESPACE.svc,DNS:*.$NAMESPACE.svc.cluster.local,IP:127.0.0.1,IP:${NODE_IP}" \
    -keyout cert.key -out cert.crt
kubectl -n "$NAMESPACE" create secret tls certificates --cert=cert.crt --key=cert.key --dry-run=client --output yaml | kubectl apply --filename -

HELM_EXTRA_SET_ARGS=
CT_ARGS=(
    --skip-clean-up
    --helm-extra-args="--timeout 4m"
)
CLEANUP_NAMESPACE=true

usage() {
    cat <<EOF 1>&2
Usage: $0 [-h] [-n <NAMESPACE>] [-a <HELM_EXTRA_SET_ARGS>] [-t <TESTS>] [-s]
Test the Trino chart

-h       Display help
-n       Kubernetes namespace, a randomly generated one is used if not provided
-a       Extra Helm set args
-t       Test names to run, comma separated; defaults to $(join_by , "${TEST_NAMES[@]}")
-s       Skip chart cleanup
EOF
}

while getopts ":a:n:t:sh:" OPTKEY; do
    case "${OPTKEY}" in
        a)
            HELM_EXTRA_SET_ARGS=${OPTARG}
            ;;
        n)
            NAMESPACE=${OPTARG}
            ;;
        t)
            IFS=, read -ra TEST_NAMES <<<"$OPTARG"
            ;;
        s)
            CLEANUP_NAMESPACE=false
            ;;
        h)
            usage
            exit 0
            ;;
        *)
            usage
            exit 1
            ;;
    esac
done
shift $((OPTIND - 1))

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"
cd "${SCRIPT_DIR}" || exit 2

CT_ARGS+=(--namespace "$NAMESPACE")

DB_PASSWORD=pass0000

DB_INSTALLATION_NAME=gateway-backend-db
helm upgrade --install ${DB_INSTALLATION_NAME} oci://registry-1.docker.io/bitnamicharts/postgresql -n "$DB_NAMESPACE" \
    --create-namespace \
    --version "16.7.27" \
    --set image.repository=bitnamilegacy/postgresql \
    --set common.resources.preset=micro \
    --set auth.username=gateway \
    --set auth.password=${DB_PASSWORD} \
    --set auth.database=gateway \
    --set primary.persistence.enabled=false
kubectl wait --for=condition=ready pod -l app.kubernetes.io/name=postgresql --timeout=300s -n "$DB_NAMESPACE"

kubectl --namespace "$NAMESPACE" create secret generic db-credentials --from-literal=PG_USER='gateway' --from-literal=PG_PASSWORD='pass0000'

result=0
for test_name in "${TEST_NAMES[@]}"; do
    echo 1>&2 ""
    echo 1>&2 "🧪 Running test $test_name"
    echo 1>&2 ""
    HELM_EXTRA_SET_ARGS="$HELM_EXTRA_SET_ARGS --set=serviceName=trino-gateway-${test_name//_/-}"
    if ! time ct install "${CT_ARGS[@]}" --charts="${testCaseCharts[$test_name]}" --helm-extra-set-args "$HELM_EXTRA_SET_ARGS ${testCases[$test_name]}"; then
        echo 1>&2 "❌ Test $test_name failed"
        echo 1>&2 "Test logs:"
        kubectl --namespace "$NAMESPACE" logs --tail=-1 --selector app.kubernetes.io/component=test --all-containers=true --prefix=true
        result=1
    else
        echo 1>&2 "✅ Test $test_name completed"
    fi
    if [ "$CLEANUP_NAMESPACE" == "true" ]; then
        for release in $(helm --namespace "$NAMESPACE" ls --short | grep -v 'prometheus-operator'); do
            echo 1>&2 "Cleaning up Helm release $release"
            helm --namespace "$NAMESPACE" delete "$release"
        done
    fi
done

if [ "$CLEANUP_NAMESPACE" == "true" ]; then
    helm -n "$DB_NAMESPACE" uninstall gateway-backend-db --ignore-not-found
    kubectl delete namespace "$DB_NAMESPACE" --ignore-not-found
    helm -n "$NAMESPACE" uninstall prometheus-operator --ignore-not-found
    kubectl delete namespace "$NAMESPACE" --ignore-not-found
    mapfile -t crds < <(kubectl api-resources --api-group=monitoring.coreos.com --output name)
    if [ ${#crds[@]} -ne 0 ]; then
        kubectl delete crd "${crds[@]}"
    fi
fi
echo Exit code $result
exit $result
