
Trino
===========

Fast distributed SQL query engine for big data analytics that helps you explore your data universe


## Configuration

The following table lists the configurable parameters of the Trino chart and their default values.

| Parameter                | Description             | Default        |
| ------------------------ | ----------------------- | -------------- |
| `image.registry` | Image registry, defaults to empty, which results in DockerHub usage | `""` |
| `image.repository` | Repository location of the Trino image, typically `organization/imagename` | `"trinodb/trino"` |
| `image.tag` | Image tag, defaults to the Trino release version specified as `appVersion` from Chart.yaml | `""` |
| `image.digest` | Optional digest value of the image specified as `sha256:abcd...`. A specified value overrides `tag`. | `""` |
| `image.useRepositoryAsSoleImageReference` | When true, only the content in `repository` is used as image reference | `false` |
| `image.pullPolicy` |  | `"IfNotPresent"` |
| `imagePullSecrets` |  | `[{"name": "registry-credentials"}]` |
| `server.workers` |  | `2` |
| `server.node.environment` |  | `"production"` |
| `server.node.dataDir` |  | `"/data/trino"` |
| `server.node.pluginDir` |  | `"/usr/lib/trino/plugin"` |
| `server.log.trino.level` |  | `"INFO"` |
| `server.config.path` |  | `"/etc/trino"` |
| `server.config.http.port` |  | `8080` |
| `server.config.https.enabled` |  | `false` |
| `server.config.https.port` |  | `8443` |
| `server.config.https.keystore.path` |  | `""` |
| `server.config.authenticationType` |  | `""` |
| `server.config.query.maxMemory` |  | `"4GB"` |
| `server.exchangeManager.name` |  | `"filesystem"` |
| `server.exchangeManager.baseDir` |  | `"/tmp/trino-local-file-system-exchange-manager"` |
| `server.workerExtraConfig` |  | `""` |
| `server.coordinatorExtraConfig` |  | `""` |
| `server.autoscaling.enabled` |  | `false` |
| `server.autoscaling.maxReplicas` |  | `5` |
| `server.autoscaling.targetCPUUtilizationPercentage` |  | `50` |
| `server.autoscaling.behavior` |  | `{}` |
| `accessControl` |  | `{}` |
| `resourceGroups` |  | `{}` |
| `additionalNodeProperties` |  | `{}` |
| `additionalConfigProperties` |  | `{}` |
| `additionalLogProperties` |  | `{}` |
| `additionalExchangeManagerProperties` |  | `{}` |
| `eventListenerProperties` |  | `{}` |
| `additionalCatalogs` |  | `{}` |
| `env` |  | `[]` |
| `envFrom` |  | `[]` |
| `initContainers` |  | `{}` |
| `sidecarContainers` |  | `{}` |
| `securityContext.runAsUser` |  | `1000` |
| `securityContext.runAsGroup` |  | `1000` |
| `shareProcessNamespace.coordinator` |  | `false` |
| `shareProcessNamespace.worker` |  | `false` |
| `service.type` |  | `"ClusterIP"` |
| `service.port` |  | `8080` |
| `auth` |  | `{}` |
| `serviceAccount.create` |  | `false` |
| `serviceAccount.name` |  | `""` |
| `serviceAccount.annotations` |  | `{}` |
| `secretMounts` |  | `[]` |
| `coordinator.jvm.maxHeapSize` |  | `"8G"` |
| `coordinator.jvm.gcMethod.type` |  | `"UseG1GC"` |
| `coordinator.jvm.gcMethod.g1.heapRegionSize` |  | `"32M"` |
| `coordinator.config.memory.heapHeadroomPerNode` |  | `""` |
| `coordinator.config.query.maxMemoryPerNode` |  | `"1GB"` |
| `coordinator.additionalJVMConfig` |  | `{}` |
| `coordinator.additionalExposedPorts` |  | `{}` |
| `coordinator.resources` |  | `{}` |
| `coordinator.livenessProbe` |  | `{}` |
| `coordinator.readinessProbe` |  | `{}` |
| `coordinator.nodeSelector` |  | `{}` |
| `coordinator.tolerations` |  | `[]` |
| `coordinator.affinity` |  | `{}` |
| `coordinator.additionalConfigFiles` |  | `{}` |
| `coordinator.additionalVolumes` | One or more additional volumes to add to the coordinator. | `[]` |
| `coordinator.additionalVolumeMounts` | One or more additional volume mounts to add to the coordinator. | `[]` |
| `coordinator.annotations` |  | `{}` |
| `coordinator.labels` |  | `{}` |
| `coordinator.secretMounts` |  | `[]` |
| `worker.jvm.maxHeapSize` |  | `"8G"` |
| `worker.jvm.gcMethod.type` |  | `"UseG1GC"` |
| `worker.jvm.gcMethod.g1.heapRegionSize` |  | `"32M"` |
| `worker.config.memory.heapHeadroomPerNode` |  | `""` |
| `worker.config.query.maxMemoryPerNode` |  | `"1GB"` |
| `worker.additionalJVMConfig` |  | `{}` |
| `worker.additionalExposedPorts` |  | `{}` |
| `worker.resources` |  | `{}` |
| `worker.livenessProbe` |  | `{}` |
| `worker.readinessProbe` |  | `{}` |
| `worker.nodeSelector` |  | `{}` |
| `worker.tolerations` |  | `[]` |
| `worker.affinity` |  | `{}` |
| `worker.additionalConfigFiles` |  | `{}` |
| `worker.additionalVolumes` | One or more additional volume mounts to add to all workers. | `[]` |
| `worker.additionalVolumeMounts` | One or more additional volume mounts to add to all workers. | `[]` |
| `worker.annotations` |  | `{}` |
| `worker.labels` |  | `{}` |
| `worker.secretMounts` |  | `[]` |
| `kafka.mountPath` |  | `"/etc/trino/schemas"` |
| `kafka.tableDescriptions` |  | `{}` |
| `commonLabels` | Labels that get applied to every resource's metadata | `{}` |
| `ingress.enabled` |  | `false` |
| `ingress.className` |  | `""` |
| `ingress.annotations` |  | `{}` |
| `ingress.hosts` |  | `[]` |
| `ingress.tls` |  | `[]` |



---
_Documentation generated by [Frigate](https://frigate.readthedocs.io)._

