# trino-gateway

![Version: 12.0.0](https://img.shields.io/badge/Version-12.0.0-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: 12](https://img.shields.io/badge/AppVersion-12-informational?style=flat-square)

A Helm chart for Trino Gateway

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| replicaCount | int | `1` |  |
| image.repository | string | `"trinodb/trino-gateway"` | Repository location of the Trino Gateway image, typically `organization/imagename` |
| image.pullPolicy | string | `"IfNotPresent"` |  |
| image.tag | string | `""` | Override the image tag whose default is the chart appVersion. |
| imagePullSecrets | list | `[]` | An optional list of references to secrets in the same namespace to use for pulling images.
Example:
```yaml
imagePullSecrets:
  - name: registry-credentials
``` |
| dataStoreSecret | object | `{"key":"","name":""}` | Provide configuration for the Trino Gateway `dataStore` in `dataStoreSecret`. This node can be left undefined if `dataStore` is defined under the config node. For production deployments sensitive values should be stored in a Secret |
| backendStateSecret | object | `{"key":"","name":""}` | Provide configuration for the Trino Gateway `backendState` in `backendStateSecret`. This should be used with health check configurations that require backend credentials. This node can be left undefined if `dataStore` is defined under the config node. |
| authenticationSecret | object | `{"key":"","name":""}` | Provide configuration for the Trino Gateway authentication configuration in `authenticationSecret`. This node can be left undefined if `dataStore` is defined under the config node. |
| config.serverConfig."node.environment" | string | `"test"` |  |
| config.serverConfig."http-server.http.port" | int | `8080` |  |
| config.dataStore.jdbcUrl | string | `"jdbc:postgresql://localhost:5432/gateway"` | The connection details for the backend database for Trino Gateway and Trino query history |
| config.dataStore.user | string | `"postgres"` |  |
| config.dataStore.password | string | `"mysecretpassword"` |  |
| config.dataStore.driver | string | `"org.postgresql.Driver"` |  |
| config.clusterStatsConfiguration.monitorType | string | `"INFO_API"` |  |
| config.modules[0] | string | `"io.trino.gateway.ha.module.HaGatewayProviderModule"` |  |
| config.modules[1] | string | `"io.trino.gateway.ha.module.ClusterStateListenerModule"` |  |
| config.modules[2] | string | `"io.trino.gateway.ha.module.ClusterStatsMonitorModule"` |  |
| config.managedApps[0] | string | `"io.trino.gateway.ha.clustermonitor.ActiveClusterMonitor"` |  |
| command | list | `["java","-XX:MinRAMPercentage=80.0","-XX:MaxRAMPercentage=80.0","-jar","/usr/lib/trino/gateway-ha-jar-with-dependencies.jar","/etc/gateway/config.yaml"]` | Startup command for Trino Gateway process. Add additional Java options and other modifications as desired. |
| service.type | string | `"ClusterIP"` |  |
| service.port | int | `8080` |  |
| ingress.enabled | bool | `false` |  |
| ingress.className | string | `""` |  |
| ingress.annotations | object | `{}` |
Example:
```yaml
kubernetes.io/ingress.class: nginx
kubernetes.io/tls-acme: "true"
``` |
| ingress.hosts | list | `[{"host":"chart-example.local","paths":[{"path":"/","pathType":"ImplementationSpecific"}]}]` | [Ingress rules](https://kubernetes.io/docs/concepts/services-networking/ingress/#ingress-rules).
Example:
```yaml
 - host: trino.example.com
   paths:
     - path: /
       pathType: ImplementationSpecific
``` |
| ingress.tls | list | `[]` | Ingress [TLS](https://kubernetes.io/docs/concepts/services-networking/ingress/#tls) configuration.
Example:
```yaml
 - secretName: chart-example-tls
   hosts:
     - chart-example.local
``` |
| resources.limits.cpu | int | `2` |  |
| resources.limits.memory | string | `"4Gi"` |  |
| resources.requests.cpu | int | `2` |  |
| resources.requests.memory | string | `"4Gi"` |  |
| autoscaling.enabled | bool | `false` |  |
| autoscaling.minReplicas | int | `1` |  |
| autoscaling.maxReplicas | int | `100` |  |
| autoscaling.targetCPUUtilizationPercentage | int | `80` | Target average CPU utilization, represented as a percentage of requested CPU. To disable scaling based on CPU, set to an empty string. |
| autoscaling.targetMemoryUtilizationPercentage | string | `""` | Target average memory utilization, represented as a percentage of requested memory. To disable scaling based on memory, set to an empty string. |
| livenessProbe.initialDelaySeconds | int | `30` |  |
| livenessProbe.periodSeconds | int | `10` |  |
| livenessProbe.failureThreshold | int | `3` |  |
| livenessProbe.timeoutSeconds | int | `1` |  |
| livenessProbe.scheme | string | `"HTTP"` |  |
| readinessProbe.initialDelaySeconds | int | `5` |  |
| readinessProbe.periodSeconds | int | `5` |  |
| readinessProbe.failureThreshold | int | `12` |  |
| readinessProbe.timeoutSeconds | int | `1` |  |
| readinessProbe.scheme | string | `"HTTP"` |  |
| volumes | object | `{}` |  |
| volumeMounts | object | `{}` |  |
| nodeSelector | object | `{}` |  |
| tolerations | list | `[]` |  |
| affinity | object | `{}` |  |
| commonLabels | object | `{}` | Labels that get applied to every resource's metadata |
| podAnnotations | object | `{}` |  |
| podLabels | object | `{}` |  |
| podSecurityContext | object | `{}` | [Pod security context](https://kubernetes.io/docs/tasks/configure-pod-container/security-context/#set-the-security-context-for-a-pod) configuration. To remove the default, set it to null (or `~`). |
| securityContext | object | `{}` | [Container security context](https://kubernetes.io/docs/tasks/configure-pod-container/security-context/#set-the-security-context-for-a-container) configuration.
Example:
```yaml
 capabilities:
   drop:
   - ALL
 readOnlyRootFilesystem: true
 runAsNonRoot: true
``` |
| serviceAccount.create | bool | `true` | Specifies whether a service account should be created |
| serviceAccount.automount | bool | `true` | Automatically mount a ServiceAccount's API credentials? |
| serviceAccount.annotations | object | `{}` | Annotations to add to the service account |
| serviceAccount.name | string | `""` | The name of the service account to use. If not set and create is true, a name is generated using the fullname template |

----------------------------------------------
Autogenerated from chart metadata using [helm-docs v1.14.2](https://github.com/norwoodj/helm-docs/releases/v1.14.2)
