#!/usr/bin/env bash

set -euo pipefail

declare -A testCases=(
    [complete_values]="--values test-values.yaml"
    [env_from]="--values test-values-with-env.yaml"
)

declare -A testCaseCharts=(
    [complete_values]="../../charts/gateway"
    [env_from]="../../charts/gateway"
)

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
HELM_EXTRA_SET_ARGS=
CT_ARGS=(
    --skip-clean-up
    --helm-extra-args="--timeout 2m"
)
CLEANUP_NAMESPACE=true
TEST_NAMES=(complete_values env_from)

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
    --version "16.2.1" \
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
    helm -n "$DB_NAMESPACE" uninstall gateway-backend-db --ignore-not-found
    kubectl delete namespace "$DB_NAMESPACE" --ignore-not-found
    kubectl delete namespace "$NAMESPACE" --ignore-not-found
    mapfile -t crds < <(kubectl api-resources --api-group=monitoring.coreos.com --output name)
    if [ ${#crds[@]} -ne 0 ]; then
        kubectl delete crd "${crds[@]}"
    fi
fi
echo Exit code $result
exit $result
