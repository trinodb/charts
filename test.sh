#!/usr/bin/env bash

set -euo pipefail

declare -A testCases=(
    [default]=""
    [single_node]="--set server.workers=0"
    [complete_values]="--values test-values.yaml"
    [overrides]="--set coordinatorNameOverride=coordinator-overridden,workerNameOverride=worker-overridden,nameOverride=overridden"
)

function join_by {
    local d=${1-} f=${2-}
    if shift 2; then
        printf %s "$f" "${@/#/$d}"
    fi
}

function uninstall_helm_repo() {
    repo_name=$1
    # clusterrole being pesky here so just uninstall in all namespaces
    # TODO: find a way to only install non-cluster level resources
    if helm list -a -A | grep -q "$repo_name"; then
        namespaces=$(helm list -a -A --filter "$repo_name" | awk 'NR>1 {print $2}' | uniq)
        for namespace in $namespaces
        do
            echo 1>&2 "Uninstalling $repo_name in $namespace"
            helm uninstall "$repo_name" -n "$namespace"
        done
    fi
}

function add_helm_repo() {
    repo_name=$1
    repo_url=$2
    echo 1>&2 "Adding Helm Repo $repo_name"
    helm repo add "$repo_name" "$repo_url"
}

function install_helm_repo() {
    repo_name=$1
    chart=$2
    version=$3
    echo 1>&2 "Installing $repo_name"
    helm install "$repo_name" "$chart" -n "$NAMESPACE" --version "$version"
}

# default to randomly generated namespace, same as chart-testing would do, but we need to load secrets into the same namespace
NAMESPACE=trino-$(LC_ALL=C tr -dc 'a-z0-9' </dev/urandom | head -c 6 || true)
HELM_EXTRA_SET_ARGS=
CT_ARGS=(--charts=charts/trino --skip-clean-up)
CLEANUP_NAMESPACE=true
TEST_NAMES=(default single_node complete_values)

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

kubectl create namespace "$NAMESPACE"
kubectl -n "$NAMESPACE" create secret tls certificates --cert=cert.crt --key=cert.key

# only install prometheus helm chart for these tests
PROMETHEUS_TESTS=(complete_values)
for test_name in "${PROMETHEUS_TESTS[@]}"; do
    found=false
    for item in "${TEST_NAMES[@]}"; do
        if [[ $item == "$test_name" ]]; then
            found=true
            break
        fi
    done
    if $found; then
        uninstall_helm_repo "prometheus-operator"
        add_helm_repo "prometheus-community" "https://prometheus-community.github.io/helm-charts"
        install_helm_repo "prometheus-operator" "prometheus-community/kube-prometheus-stack" "60.0.2"
        kubectl rollout status --watch deployments -l release=prometheus-operator -n "$NAMESPACE"
    fi
done


CT_ARGS+=(--namespace "$NAMESPACE")

result=0
for test_name in "${TEST_NAMES[@]}"; do
    echo 1>&2 ""
    echo 1>&2 "🧪 Running test $test_name"
    echo 1>&2 ""
    if ! time ct install "${CT_ARGS[@]}" --helm-extra-set-args "$HELM_EXTRA_SET_ARGS ${testCases[$test_name]}"; then
        echo 1>&2 "❌ Test $test_name failed"
        echo 1>&2 "Test logs:"
        # Get list of failed test pods
        failed_tests=$(kubectl get pods --namespace "$NAMESPACE" \
                    --field-selector=status.phase=Failed \
                    --selector app.kubernetes.io/component=test \
                    -o jsonpath='{.items[*].metadata.name}')

        # Iterate through each failed test pod
        for pod in $failed_tests; do
            # Get list of failed containers in the pod
            containers=$(kubectl get pod "$pod" --namespace "$NAMESPACE" \
                -o jsonpath="{range .status.containerStatuses[?(@.state.terminated.exitCode != 0)]}{.name}{' '}{end}")

            # Check if there are any failed containers
            if [ -n "$containers" ]; then
                # Iterate through each failed container
                for container in $containers; do
                    echo 1>&2 "$pod $container"
                    # Get logs for the failed container
                    kubectl logs -n "$NAMESPACE" "$pod" "$container" --tail=-1
                done
            fi
        done

        result=1
    else
        echo 1>&2 "✅ Test $test_name completed"
    fi
    if [ "$CLEANUP_NAMESPACE" == "true" ]; then
        for release in $(helm --namespace "$NAMESPACE" ls --all --short); do
            echo 1>&2 "Cleaning up Helm release $release"
            helm --namespace "$NAMESPACE" delete "$release"
        done
    fi
done

if [ "$CLEANUP_NAMESPACE" == "true" ]; then
    kubectl delete namespace "$NAMESPACE"
fi

exit $result
