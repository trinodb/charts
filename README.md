
Trino Community Kubernetes Helm Charts
===========
[![CI/CD](https://github.com/trinodb/charts/actions/workflows/ci-cd.yaml/badge.svg?branch=main)](https://github.com/trinodb/charts/actions/workflows/ci-cd.yaml)

A repository of Helm charts for the Trino community. The following charts are
included:

* `trino/trino` for [Trino](https://trino.io/)
* `trino/trino-gateway` for [Trino Gateway](https://trinodb.github.io/trino-gateway)

## Usage

[Helm](https://helm.sh) must be installed to use the charts.
Refer to Helm's [documentation](https://helm.sh/docs/) to get started.

Once Helm is set up properly, add the repo as follows:

```console
helm repo add trino https://trinodb.github.io/charts/
```

Run `helm search repo trino` to see the latest charts with the string `trino` in
the name to get an output similar to the following:

```
NAME               	CHART VERSION	APP VERSION	DESCRIPTION
trino/trino        	1.44.0       	483        	Fast distributed SQL query engine for big data ...
trino/trino-gateway	1.21.0       	21         	A Helm chart for Trino Gateway
```

Use `helm search repo trino -l` for information about all available versions.

After configuring your Kubernetes cluster, you can install Trino with the chart
`trino/trino` using:

```console
helm install my-trino trino/trino --version 1.44.0
```

The charts are also published as OCI artifacts to the GitHub Container
Registry, so they can be pulled through a registry proxy that does not support
Helm chart repositories. Install from there without adding a repo using:

```console
helm install my-trino oci://ghcr.io/trinodb/charts/trino --version 1.44.0
```

Also, you can check the manifests using:

```console
helm template my-trino trino/trino --namespace <YOUR_NAMESPACE>
```

Similarly install Trino Gateway with the `trino/trino-gateway` chart.

## Documentation

More information about Trino, Trino Gateway, and the charts is available in the
following resources:

* [Trino Kubernetes documentation](https://trino.io/docs/current/installation/kubernetes.html)
* [trino/trino chart configuration](./charts/trino/README.md)
* [Trino documentation](https://trino.io/docs/current/index.html)
* [Trino Gateway Kubernetes documentation](https://trinodb.github.io/trino-gateway/installation/#helm)
* [trino/trino-gateway chart configuration](./charts/gateway/README.md)
* [Trino Gateway documentation](https://trinodb.github.io/trino-gateway)

## Development

Each test case is a values file under a chart's `ci` directory. `ct lint`
validates every chart against every one of them, and `tests/run.sh` installs the
chart once per case into a throwaway namespace and runs the chart's
[Helm tests](charts/trino/templates/tests) against it.

```console
brew install helm kind chart-testing
kind create cluster
./tests/run.sh trino
```

Some cases need something else in the cluster first. Those prerequisites are a
Helm chart of their own, `tests/fixtures`, and `--fixtures` selects the ones to
install, so a run only pays for what it uses:

| Fixture | Needed by |
| --- | --- |
| `prometheus` | `trino/complete`, `gateway/complete` |
| `keda` | `trino/complete` |
| `postgres` | `trino/resource-groups-properties`, every `gateway` case |
| `gateway-api` | `trino/gateway`, `trino/gateway-https` |

```console
./tests/run.sh trino --cases complete --fixtures prometheus,keda
./tests/run.sh gateway --fixtures all
```

Use `--cases` to run only some of them, `--tag` to test a different Trino
version, and `--keep` to leave the namespace in place so failing resources can be
inspected. See `./tests/run.sh --help` for the rest.

```console
./tests/run.sh trino --cases graceful-shutdown --keep
```

The `prometheus` and `keda` fixtures create cluster scoped resources that belong
to their Helm release: CRDs, ClusterRoles, ClusterRoleBindings and an APIService.
Only one run using them can be in flight per cluster, and `tests/run.sh` has to
uninstall the release rather than only delete the namespace, which is what its
teardown does. If such a run is killed before it can clean up, those resources
are left owned by a release that no longer exists and the next run cannot adopt
them. Recover by deleting whatever the dead release still owns:

```console
for kind in clusterrole clusterrolebinding apiservice crd; do
  kubectl get "$kind" -o json |
    jq -r --arg ns "$STALE_NAMESPACE" \
      '.items[] | select(.metadata.annotations["meta.helm.sh/release-namespace"] == $ns)
       | "\(.kind)/\(.metadata.name)"'
done | xargs -r kubectl delete
```

The documentation is automatically generated from the chart files. Install a
git hook to have it automatically updated when committing changes. Make sure
you [install the pre-commit binary](https://pre-commit.com/#install), then run:

```console
pre-commit install
pre-commit install-hooks
```
