#!/usr/bin/env bash

set -euo pipefail

# Gateway API publishes no Helm chart and its CRDs are a 1.2MB release asset, so
# this is the one test dependency no dependency bot can bump. Everything else is
# pinned in tests/fixtures/Chart.yaml or tests/fixtures/values.yaml.
GATEWAY_API_VERSION=v1.6.2

SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" >/dev/null && pwd)
FIXTURES_CHART=$SCRIPT_DIR/fixtures
ALL_FIXTURES=(prometheus keda postgres gateway-api)

usage() {
    cat <<EOF 1>&2
Usage: $0 <trino|gateway> [options]

Install a chart once per test case into a throwaway namespace and run the chart's
Helm tests against it.

  --cases <a,b,c>      Cases to run; defaults to every charts/<chart>/ci/*-values.yaml
  --fixtures <a,b|all> Cluster prerequisites to install: $(IFS=,; echo "${ALL_FIXTURES[*]}").
                       Defaults to none. The TLS certificate and the exchange
                       manager claim are always created, they cost nothing.
  --tag <tag>          Override image.tag
  --set <key=value>    Extra Helm values, repeatable
  --namespace <ns>     Namespace to use; a random one is generated otherwise
  --retain             Leave each release installed instead of deleting it before
                       the next case, so the cases coexist in one namespace
  --keep               Skip teardown, to inspect what the tests left behind
  -h, --help           Display help

Examples:
  $0 trino --cases graceful-shutdown --keep
  $0 trino --cases complete --fixtures prometheus,keda
  $0 gateway --fixtures all
EOF
}

chart=
cases_arg=
fixtures_arg=
tag=
namespace=
retain=false
keep=false
extra_set=()

while [ $# -gt 0 ]; do
    case $1 in
        trino | gateway)
            if [ -n "$chart" ]; then
                echo 1>&2 "Only one chart can be tested at a time"
                exit 1
            fi
            chart=$1
            ;;
        --cases) cases_arg=${2:?--cases requires a value}; shift ;;
        --fixtures) fixtures_arg=${2:?--fixtures requires a value}; shift ;;
        --tag) tag=${2:?--tag requires a value}; shift ;;
        --set) extra_set+=(--set "${2:?--set requires a value}"); shift ;;
        --namespace) namespace=${2:?--namespace requires a value}; shift ;;
        --retain) retain=true ;;
        --keep) keep=true ;;
        -h | --help) usage; exit 0 ;;
        *)
            echo 1>&2 "Unknown argument: $1"
            usage
            exit 1
            ;;
    esac
    shift
done

if [ -z "$chart" ]; then
    echo 1>&2 "A chart is required"
    usage
    exit 1
fi

case $chart in
    trino) chart_dir=$(cd -- "$SCRIPT_DIR/../charts/trino" >/dev/null && pwd) ;;
    gateway) chart_dir=$(cd -- "$SCRIPT_DIR/../charts/gateway" >/dev/null && pwd) ;;
esac

if [ -n "$cases_arg" ]; then
    IFS=, read -ra cases <<<"$cases_arg"
else
    cases=()
    for values in "$chart_dir"/ci/*-values.yaml; do
        cases+=("$(basename "$values" -values.yaml)")
    done
fi

fixtures=()
case $fixtures_arg in
    all) fixtures=("${ALL_FIXTURES[@]}") ;;
    "" | none) ;;
    *) IFS=, read -ra fixtures <<<"$fixtures_arg" ;;
esac

has_fixture() {
    local wanted=$1 fixture
    for fixture in ${fixtures[@]+"${fixtures[@]}"}; do
        if [ "$fixture" = "$wanted" ]; then
            return 0
        fi
    done
    return 1
}

for fixture in ${fixtures[@]+"${fixtures[@]}"}; do
    if ! printf '%s\n' "${ALL_FIXTURES[@]}" | grep -qxF "$fixture"; then
        echo 1>&2 "Unknown fixture: $fixture, expected one of ${ALL_FIXTURES[*]}"
        exit 1
    fi
done

for case_name in "${cases[@]}"; do
    if [ ! -f "$chart_dir/ci/$case_name-values.yaml" ]; then
        echo 1>&2 "Unknown case: $case_name, expected $chart_dir/ci/$case_name-values.yaml"
        exit 1
    fi
done

if [ -z "$namespace" ]; then
    namespace=$chart-$(openssl rand -hex 3)
fi

work_dir=$(mktemp -d)

cleanup() {
    rm -rf "$work_dir"
    if [ "$keep" = true ]; then
        echo 1>&2 ""
        echo 1>&2 "Namespace $namespace left in place. Clean it up with:"
        echo 1>&2 "    kubectl delete namespace $namespace"
        return
    fi
    echo 1>&2 ""
    echo 1>&2 "Deleting namespace $namespace"
    # Uninstall the fixtures release first. KEDA registers a cluster scoped
    # APIService backed by a Service in this namespace, so deleting the namespace
    # first leaves that APIService unavailable and namespace finalization then
    # blocks forever on failed API discovery. Letting Helm remove what it owns
    # avoids deleting cluster scoped resources by hand, which is how the old
    # scripts could take unrelated CRDs with them on a shared cluster.
    helm uninstall fixtures --namespace "$namespace" --ignore-not-found --wait >/dev/null || true
    kubectl delete namespace "$namespace" --ignore-not-found
}
trap cleanup EXIT

echo 1>&2 "Chart:     $chart"
echo 1>&2 "Cases:     ${cases[*]}"
echo 1>&2 "Fixtures:  ${fixtures[*]:-none}"
echo 1>&2 "Namespace: $namespace"

kubectl create namespace "$namespace" --dry-run=client --output yaml | kubectl apply --filename -

echo 1>&2 "Generating a self-signed TLS certificate"
node_ip=$(kubectl get nodes --output jsonpath='{.items[0].status.addresses[0].address}')
openssl req -new -newkey rsa:4096 -days 365 -nodes -x509 \
    -subj "/O=Trino Software Foundation" \
    -addext "subjectAltName=DNS:trino-gateway,DNS:localhost,DNS:*.$namespace,DNS:*.$namespace.svc,DNS:*.$namespace.svc.cluster.local,IP:127.0.0.1,IP:$node_ip" \
    -keyout "$work_dir/cert.key" -out "$work_dir/cert.crt"

fixture_args=(
    --set-file "tls.crt=$work_dir/cert.crt"
    --set-file "tls.key=$work_dir/cert.key"
)
if has_fixture prometheus; then
    fixture_args+=(--set kube-prometheus-stack.enabled=true)
fi
if has_fixture keda; then
    fixture_args+=(--set keda.enabled=true)
fi
if has_fixture postgres; then
    fixture_args+=(--set postgres.enabled=true --set dbCredentials.enabled=true)
fi

# Helm resolves each dependency's repository URL through the local repo list, so a
# fresh checkout has to register them first. Reading them back out of the chart
# keeps the URLs declared in exactly one place, and the alias is prefixed so it
# cannot clobber a repo the user already has under the same name.
helm dependency list "$FIXTURES_CHART" |
    awk 'NR > 1 && $3 ~ /^https?:/ { print $1, $3 }' |
    while read -r dependency repository; do
        helm repo add "fixtures-$dependency" "$repository" --force-update >/dev/null
    done

# Helm requires declared dependencies to be present even when their condition is
# false, so this runs whatever the chart under test needs.
helm dependency build "$FIXTURES_CHART" >/dev/null
helm upgrade --install fixtures "$FIXTURES_CHART" --namespace "$namespace" \
    "${fixture_args[@]}" --wait --timeout 8m

if has_fixture gateway-api; then
    echo 1>&2 "Installing Gateway API CRDs $GATEWAY_API_VERSION"
    kubectl apply --filename "https://github.com/kubernetes-sigs/gateway-api/releases/download/$GATEWAY_API_VERSION/standard-install.yaml"
    kubectl wait --for condition=established --timeout=60s crd/gateways.gateway.networking.k8s.io
    kubectl wait --for condition=established --timeout=60s crd/httproutes.gateway.networking.k8s.io
fi

install_args=(--namespace "$namespace" --wait --timeout 6m)
if [ -n "$tag" ]; then
    install_args+=(--set "image.tag=$tag")
fi

result=0
for case_name in "${cases[@]}"; do
    release=$chart-$case_name
    echo 1>&2 ""
    echo 1>&2 "🧪 $chart/$case_name"
    echo 1>&2 ""
    if helm install "$release" "$chart_dir" \
        --values "$chart_dir/ci/$case_name-values.yaml" \
        "${install_args[@]}" ${extra_set[@]+"${extra_set[@]}"} \
        && helm test "$release" --namespace "$namespace" --timeout 6m; then
        echo 1>&2 "✅ $chart/$case_name"
    else
        result=1
        echo 1>&2 "❌ $chart/$case_name"
        kubectl --namespace "$namespace" get pods \
            --selector "app.kubernetes.io/instance=$release" 1>&2 || true
        kubectl --namespace "$namespace" logs \
            --selector "app.kubernetes.io/instance=$release" \
            --all-containers --prefix --tail=-1 1>&2 || true
    fi
    if [ "$retain" = false ]; then
        helm uninstall "$release" --namespace "$namespace" --ignore-not-found >/dev/null
    fi
done

exit $result
