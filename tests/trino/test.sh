#!/usr/bin/env bash

set -euo pipefail

declare -A testCases=(
    [default]=""
    [single_node]="--set server.workers=0,coordinator.config.nodeScheduler.includeCoordinator=true"
    [complete_values]="--values test-values.yaml"
    [overrides]="--set coordinatorNameOverride=coordinator-overridden,workerNameOverride=worker-overridden,nameOverride=overridden"
    [access_control_properties_values]="--values test-access-control-properties-values.yaml"
    [exchange_manager_values]="--values test-exchange-manager-values.yaml"
    [graceful_shutdown]="--values test-graceful-shutdown-values.yaml"
    [resource_groups_properties]="--values test-resource-groups-properties-values.yaml"
    [dynamic_catalogs]="--values dyncat-values.yaml"
)

declare -A testCaseCharts=(
    [default]="../../charts/trino"
    [single_node]="../../charts/trino"
    [complete_values]="../../charts/trino"
    [overrides]="../../charts/trino"
    [access_control_properties_values]="../../charts/trino"
    [exchange_manager_values]="../../charts/trino"
    [graceful_shutdown]="../../charts/trino"
    [resource_groups_properties]="../../charts/trino"
    [dynamic_catalogs]="../../charts/trino"
)

function join_by {
    local d=${1-} f=${2-}
    if shift 2; then
        printf %s "$f" "${@/#/$d}"
    fi
}

# default to randomly generated namespace, same as chart-testing would do, but we need to load secrets into the same namespace
NAMESPACE=trino-$(LC_ALL=C tr -dc 'a-z0-9' </dev/urandom | head -c 6 || true)
DB_NAMESPACE=postgresql
KEDA_NAMESPACE=keda
HELM_EXTRA_SET_ARGS=
CT_ARGS=(
    --skip-clean-up
    --helm-extra-args="--timeout 2m"
)
CLEANUP_NAMESPACE=true
TEST_NAMES=(default single_node complete_values access_control_properties_values exchange_manager_values graceful_shutdown resource_groups_properties dynamic_catalogs)

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

echo 1>&2 "Generating a self-signed TLS certificate"
openssl req -new -newkey rsa:4096 -days 365 -nodes -x509 \
    -subj "/O=Trino Software Foundation" \
    -addext "subjectAltName=DNS:localhost,DNS:*.$NAMESPACE,DNS:*.$NAMESPACE.svc,DNS:*.$NAMESPACE.svc.cluster.local,IP:127.0.0.1" \
    -keyout cert.key -out cert.crt

kubectl create namespace "$NAMESPACE" --dry-run=client --output yaml | kubectl apply --filename -
kubectl -n "$NAMESPACE" create secret tls "$NAMESPACE"-certificates --cert=cert.crt --key=cert.key --dry-run=client --output yaml | kubectl apply --filename -
cat <<YAML | kubectl -n "$NAMESPACE" apply -f-
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: exchange-manager-pvc
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 128Mi
YAML
cat <<YAML | kubectl -n "$NAMESPACE" create -f -
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: catalogs-pvc
spec:
  accessModes:
    - ReadWriteOnce
  storageClassName: standard
  resources:
    requests:
      storage: 30Mi
YAML

# only install the Prometheus and KEDA Helm charts when running the `complete_values` test
if printf '%s\0' "${TEST_NAMES[@]}" | grep -qwz complete_values; then
    # prometheus
    helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
    helm upgrade --install prometheus-operator prometheus-community/kube-prometheus-stack -n "$NAMESPACE" \
        --version "60.0.2" \
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
    # keda
    helm repo add kedacore https://kedacore.github.io/charts
    helm upgrade --install keda kedacore/keda -n "$KEDA_NAMESPACE" \
        --create-namespace \
        --version "2.16.0" \
        --set webhooks.enabled=false \
        --set asciiArt=false
    kubectl rollout status --watch deployments -l app.kubernetes.io/instance=keda -n "$KEDA_NAMESPACE"
fi

# only install the PostgreSQL Helm chart when running the `resource_groups_properties` test
if printf '%s\0' "${TEST_NAMES[@]}" | grep -qwz resource_groups_properties; then
    helm upgrade --install trino-resource-groups-db oci://registry-1.docker.io/bitnamicharts/postgresql -n "$DB_NAMESPACE" \
        --create-namespace \
        --version "16.2.1" \
        --set auth.username=trino \
        --set auth.password=pass0000 \
        --set auth.database=resource_groups \
        --set primary.persistence.enabled=false
    kubectl wait --for=condition=ready pod -l app.kubernetes.io/name=postgresql --timeout=300s -n "$DB_NAMESPACE"
fi

CT_ARGS+=(--namespace "$NAMESPACE")

result=0
for test_name in "${TEST_NAMES[@]}"; do
    echo 1>&2 ""
    echo 1>&2 "🧪 Running test $test_name"
    echo 1>&2 ""
    if ! time ct install "${CT_ARGS[@]}" --charts="${testCaseCharts[$test_name]}" --helm-extra-set-args "$HELM_EXTRA_SET_ARGS ${testCases[$test_name]}"; then
        echo 1>&2 "❌ Test $test_name failed"
        echo 1>&2 "Test logs:"
        kubectl --namespace "$NAMESPACE" logs --tail=-1 --selector app.kubernetes.io/component=test --all-containers=true
        result=1
    else
        echo 1>&2 "✅ Test $test_name completed"
    fi
    if [ "$CLEANUP_NAMESPACE" == "true" ]; then
        for release in $(helm --namespace "$NAMESPACE" ls --all --short | grep -v 'prometheus-operator'); do
            echo 1>&2 "Cleaning up Helm release $release"
            helm --namespace "$NAMESPACE" delete "$release"
        done
    fi
done

if [ "$CLEANUP_NAMESPACE" == "true" ]; then
    helm -n "$DB_NAMESPACE" uninstall trino-resource-groups-db --ignore-not-found
    kubectl delete namespace "$DB_NAMESPACE" --ignore-not-found
    helm -n "$NAMESPACE" uninstall prometheus-operator --ignore-not-found
    kubectl delete namespace "$NAMESPACE"
    helm -n "$KEDA_NAMESPACE" uninstall keda --ignore-not-found
    kubectl delete namespace "$KEDA_NAMESPACE"
    for api_group in monitoring.coreos.com eventing.keda.sh keda.sh; do
        mapfile -t crds < <(kubectl api-resources --api-group="$api_group" --output name)
        if [ ${#crds[@]} -ne 0 ]; then
            kubectl delete crd "${crds[@]}"
        fi
    done
fi

exit $result
