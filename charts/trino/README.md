# trino

![Version: 0.20.0](https://img.shields.io/badge/Version-0.20.0-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: 446](https://img.shields.io/badge/AppVersion-446-informational?style=flat-square)

Fast distributed SQL query engine for big data analytics that helps you explore your data universe

**Homepage:** <https://trino.io/>

## Source Code

* <https://github.com/trinodb/charts>
* <https://github.com/trinodb/trino/tree/master/core/docker>

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| accessControl | object | `{}` |  |
| additionalCatalogs | object | `{}` |  |
| additionalConfigProperties | object | `{}` |  |
| additionalExchangeManagerProperties | object | `{}` |  |
| additionalLogProperties | object | `{}` |  |
| additionalNodeProperties | object | `{}` |  |
| auth | object | `{}` |  |
| commonLabels | object | `{}` |  |
| coordinator.additionalConfigFiles | object | `{}` |  |
| coordinator.additionalExposedPorts | object | `{}` |  |
| coordinator.additionalJVMConfig | list | `[]` |  |
| coordinator.additionalVolumeMounts | list | `[]` |  |
| coordinator.additionalVolumes | list | `[]` |  |
| coordinator.affinity | object | `{}` |  |
| coordinator.annotations | object | `{}` |  |
| coordinator.config.memory.heapHeadroomPerNode | string | `""` |  |
| coordinator.config.query.maxMemoryPerNode | string | `"1GB"` |  |
| coordinator.jvm.gcMethod.g1.heapRegionSize | string | `"32M"` |  |
| coordinator.jvm.gcMethod.type | string | `"UseG1GC"` |  |
| coordinator.jvm.maxHeapSize | string | `"8G"` |  |
| coordinator.labels | object | `{}` |  |
| coordinator.lifecycle | object | `{}` |  |
| coordinator.livenessProbe | object | `{}` |  |
| coordinator.nodeSelector | object | `{}` |  |
| coordinator.readinessProbe | object | `{}` |  |
| coordinator.resources | object | `{}` |  |
| coordinator.secretMounts | list | `[]` |  |
| coordinator.terminationGracePeriodSeconds | int | `30` |  |
| coordinator.tolerations | list | `[]` |  |
| env | list | `[]` |  |
| envFrom | list | `[]` |  |
| eventListenerProperties | object | `{}` |  |
| image.digest | string | `""` |  |
| image.pullPolicy | string | `"IfNotPresent"` |  |
| image.registry | string | `""` |  |
| image.repository | string | `"trinodb/trino"` |  |
| image.tag | string | `""` |  |
| image.useRepositoryAsSoleImageReference | bool | `false` |  |
| imagePullSecrets[0].name | string | `"registry-credentials"` |  |
| ingress.annotations | object | `{}` |  |
| ingress.className | string | `""` |  |
| ingress.enabled | bool | `false` |  |
| ingress.hosts | list | `[]` |  |
| ingress.tls | list | `[]` |  |
| initContainers | object | `{}` |  |
| kafka.mountPath | string | `"/etc/trino/schemas"` |  |
| kafka.tableDescriptions | object | `{}` |  |
| resourceGroups | object | `{}` |  |
| secretMounts | list | `[]` |  |
| securityContext.runAsGroup | int | `1000` |  |
| securityContext.runAsUser | int | `1000` |  |
| server.autoscaling.behavior | object | `{}` |  |
| server.autoscaling.enabled | bool | `false` |  |
| server.autoscaling.maxReplicas | int | `5` |  |
| server.autoscaling.targetCPUUtilizationPercentage | int | `50` |  |
| server.config.authenticationType | string | `""` |  |
| server.config.http.port | int | `8080` |  |
| server.config.https.enabled | bool | `false` |  |
| server.config.https.keystore.path | string | `""` |  |
| server.config.https.port | int | `8443` |  |
| server.config.path | string | `"/etc/trino"` |  |
| server.config.query.maxMemory | string | `"4GB"` |  |
| server.coordinatorExtraConfig | string | `""` |  |
| server.exchangeManager.baseDir | string | `"/tmp/trino-local-file-system-exchange-manager"` |  |
| server.exchangeManager.name | string | `"filesystem"` |  |
| server.log.trino.level | string | `"INFO"` |  |
| server.node.dataDir | string | `"/data/trino"` |  |
| server.node.environment | string | `"production"` |  |
| server.node.pluginDir | string | `"/usr/lib/trino/plugin"` |  |
| server.workerExtraConfig | string | `""` |  |
| server.workers | int | `2` |  |
| service.port | int | `8080` |  |
| service.type | string | `"ClusterIP"` |  |
| serviceAccount.annotations | object | `{}` |  |
| serviceAccount.create | bool | `false` |  |
| serviceAccount.name | string | `""` |  |
| shareProcessNamespace.coordinator | bool | `false` |  |
| shareProcessNamespace.worker | bool | `false` |  |
| sidecarContainers | object | `{}` |  |
| worker.additionalConfigFiles | object | `{}` |  |
| worker.additionalExposedPorts | object | `{}` |  |
| worker.additionalJVMConfig | list | `[]` |  |
| worker.additionalVolumeMounts | list | `[]` |  |
| worker.additionalVolumes | list | `[]` |  |
| worker.affinity | object | `{}` |  |
| worker.annotations | object | `{}` |  |
| worker.config.memory.heapHeadroomPerNode | string | `""` |  |
| worker.config.query.maxMemoryPerNode | string | `"1GB"` |  |
| worker.jvm.gcMethod.g1.heapRegionSize | string | `"32M"` |  |
| worker.jvm.gcMethod.type | string | `"UseG1GC"` |  |
| worker.jvm.maxHeapSize | string | `"8G"` |  |
| worker.labels | object | `{}` |  |
| worker.lifecycle | object | `{}` |  |
| worker.livenessProbe | object | `{}` |  |
| worker.nodeSelector | object | `{}` |  |
| worker.readinessProbe | object | `{}` |  |
| worker.resources | object | `{}` |  |
| worker.secretMounts | list | `[]` |  |
| worker.terminationGracePeriodSeconds | int | `30` |  |
| worker.tolerations | list | `[]` |  |

----------------------------------------------
Autogenerated from chart metadata using [helm-docs v1.13.1](https://github.com/norwoodj/helm-docs/releases/v1.13.1)
