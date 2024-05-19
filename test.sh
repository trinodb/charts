#!/usr/bin/env bash

set -euo pipefail

usage() {
    cat <<EOF 1>&2
Usage: $0 [-h] [-n <NAMESPACE>] [-a <HELM_EXTRA_SET_ARGS>]
Test the Trino chart

-h       Display help
-n       Kubernetes namespace, a randomly generated one is used if not provided
-a       Extra Helm set args
-s       Skip chart cleanup
EOF
}

# default to randomly generated namespace, same as chart-testing would do, but we need to load secrets into the same namespace
NAMESPACE=trino-$(LC_ALL=C tr -dc 'a-z0-9' </dev/urandom | head -c 6 || true)
HELM_EXTRA_SET_ARGS=
CT_ARGS=()
CLEANUP_NAMESPACE=true

while getopts ":a:n:sh:" OPTKEY; do
    case "${OPTKEY}" in
        a)
            HELM_EXTRA_SET_ARGS=${OPTARG}
            ;;
        n)
            NAMESPACE=${OPTARG}
            ;;
        s)
            CT_ARGS+=(--skip-clean-up)
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

echo "Generating a self-signed TLS certificate"
openssl req -new -newkey rsa:4096 -days 365 -nodes -x509 \
    -subj "/O=Trino Software Foundation" \
    -addext "subjectAltName=DNS:localhost,DNS:*.$NAMESPACE,DNS:*.$NAMESPACE.svc,DNS:*.$NAMESPACE.svc.cluster.local,IP:127.0.0.1" \
    -keyout cert.key -out cert.crt

kubectl create namespace "$NAMESPACE"
kubectl -n "$NAMESPACE" create secret tls certificates --cert=cert.crt --key=cert.key

CT_ARGS+=(--namespace "$NAMESPACE")

ct install "${CT_ARGS[@]}" --helm-extra-set-args "$HELM_EXTRA_SET_ARGS"
ct install "${CT_ARGS[@]}" --helm-extra-set-args "$HELM_EXTRA_SET_ARGS --set server.workers=0"
ct install "${CT_ARGS[@]}" --helm-extra-set-args "$HELM_EXTRA_SET_ARGS --values test-values.yaml"

if [ "$CLEANUP_NAMESPACE" == "true" ]; then
    kubectl delete namespace "$NAMESPACE"
fi
