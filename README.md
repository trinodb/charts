
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
trino/trino        	1.36.0       	468        	Fast distributed SQL query engine for big data ...
trino/trino-gateway	1.13.2       	13         	A Helm chart for Trino Gateway
```

Use `helm search repo trino -l` for information about all available versions.

After configuring your Kubernetes cluster, you can install Trino with the chart
`trino/trino` using:

```console
helm install my-trino trino/trino --version 1.36.0
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

To test the chart, install it into a Kubernetes cluster. Use `kind` to create a
Kubernetes cluster running in a container, and `chart-testing` to install the
chart and run [tests](charts/trino/templates/tests).

```console
brew install helm kind chart-testing
kind create cluster
ct install
```

To run tests with specific values:
```console
ct install --helm-extra-set-args "--set image.tag=467"
```

Use the `test.sh` script to run a suite of tests, with different chart values.
If some of the tests fail, use the `-s` flag to skip cleanup and inspect the
resources installed in the Kubernetes cluster. Use `-n` to use a specific
namespace, not a randomly generated one. Use `-t` to run only selected tests.
See the command help (`-h`) for a list of available tests.

Example:
```console
./test.sh -n trino -s -t default
```

The documentation is automatically generated from the chart files. Install a
git hook to have it automatically updated when committing changes. Make sure
you [install the pre-commit binary](https://pre-commit.com/#install), then run:

```console
pre-commit install
pre-commit install-hooks
```
