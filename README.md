
Trino Community Kubernetes Helm Charts
===========
[![Release Trino Chart](https://github.com/trinodb/charts/actions/workflows/release.yaml/badge.svg?branch=main)](https://github.com/trinodb/charts/actions/workflows/release.yaml)

Fast distributed SQL query engine for big data analytics that helps you explore your data universe


## Usage

[Helm](https://helm.sh) must be installed to use the charts.
Please refer to Helm's [documentation](https://helm.sh/docs/) to get started.

Once Helm is set up properly, add the repo as follows:

```console
helm repo add trino https://trinodb.github.io/charts/
```

You can then run `helm search repo trino` to see the charts.

Then you can install chart using:

```console
helm install my-trino trino/trino --version 0.2.0
```

## Documentation

You can find documentation about the chart [here](./charts/trino/README.md).
