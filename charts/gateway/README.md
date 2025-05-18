# trino-gateway

![Version: 1.15.1](https://img.shields.io/badge/Version-1.15.1-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: 15](https://img.shields.io/badge/AppVersion-15-informational?style=flat-square)

A Helm chart for Trino Gateway

**Homepage:** <https://trinodb.github.io/trino-gateway/>

## Source Code

* <https://github.com/trinodb/charts>
* <https://github.com/trinodb/trino-gateway>

## Values
* `replicaCount` - int, default: `1`
* `image.repository` - string, default: `"trinodb/trino-gateway"`  

  Repository location of the Trino Gateway image, typically `organization/imagename`
* `image.pullPolicy` - string, default: `"IfNotPresent"`
* `image.tag` - string, default: `""`  

  Override the image tag whose default is the chart appVersion.
* `imagePullSecrets` - list, default: `[]`  

  An optional list of references to secrets in the same namespace to use for pulling images.
  Example:
  ```yaml
  imagePullSecrets:
    - name: registry-credentials
  ```
* `envFrom` - list, default: `[]`  

  A list of secrets and configmaps to mount into the init container as environment variables.
  Example:
  ```yaml
  envFrom:
    - secretRef:
        name: password-secret
  ```
* `initContainers` - object, default: `{}`  

  Additional [containers that run to completion](https://kubernetes.io/docs/concepts/workloads/pods/init-containers/) during pod initialization.
  Example:
  ```yaml
  initContainers:
    - name: wait-for-service
      image: busybox:1.28
      imagePullPolicy: IfNotPresent
      command: ['sh', '-c', "until nslookup {{ .Values.serviceName }}.$(cat /var/run/secrets/kubernetes.io/serviceaccount/namespace).svc.cluster.local; do echo waiting for myservice; sleep 2; done"]
    - name: init-sleep
      image: busybox:1.28
      imagePullPolicy: IfNotPresent
      command: ['sh', '-c', 'echo The worker is running! && sleep 3600']
  ```
* `config.serverConfig."node.environment"` - string, default: `"test"`
* `config.serverConfig."http-server.http.port"` - int, default: `8080`
* `config.serverConfig."http-server.http.enabled"` - bool, default: `true`
* `config.dataStore.jdbcUrl` - string, default: `"jdbc:postgresql://localhost:5432/gateway"`  

  The connection details for the backend database for Trino Gateway and Trino query history
* `config.dataStore.user` - string, default: `"postgres"`
* `config.dataStore.password` - string, default: `"mysecretpassword"`
* `config.dataStore.driver` - string, default: `"org.postgresql.Driver"`
* `config.clusterStatsConfiguration.monitorType` - string, default: `"INFO_API"`
* `command` - list, default: `["java","-XX:MinRAMPercentage=80.0","-XX:MaxRAMPercentage=80.0","-jar","/usr/lib/trino-gateway/gateway-ha-jar-with-dependencies.jar","/etc/trino-gateway/config.yaml"]`  

  Startup command for Trino Gateway process. Add additional Java options and other modifications as desired.
* `service` - object, default: `{"ports":[{"name":"gateway","protocol":"TCP"}],"type":"ClusterIP"}`  

  Service for accessing the gateway. The contents of this dictionary are used  for the [service spec](https://kubernetes.io/docs/concepts/services-networking/service/#type-nodeport). The `port` and `targetPort` of the first element of the ports list will automatically be set to the value of `config.serverConfig."http-server.http[s].port"`. If both https and http ports are defined the https port is used. In this case, an additional service for the http port must be configured manually. Additional ports, such as for JMX or a Java Agent can be configured by adding elements to the ports list. The selector is also automatically configured. All other values are passed through as is.  Example configuration for exposing both https and http:
  ```yaml
   service:
     type: NodePort
     ports:
       - protocol: TCP
         name: request
         nodePort: 30443
         # targetPort and port will automatically pulled from serverConfig.http-server.https.port
       - protocol: TCP
         name: gateway-http
         nodePort: 30080
         port: 8080
         # targetPort must be explicitly set to the same value as serverConfig.http-server.http.port
         targetPort: 8080
  ```
* `serviceName` - string, default: `"trino-gateway"`  

  Set a custom name for the gateway service
* `ingress.enabled` - bool, default: `false`
* `ingress.className` - string, default: `""`
* `ingress.annotations` - object, default: `{}`
* `ingress.hosts` - list, default: `[{"host":"chart-example.local","paths":[{"path":"/","pathType":"ImplementationSpecific"}]}]`  

  [Ingress rules](https://kubernetes.io/docs/concepts/services-networking/ingress/#ingress-rules).
  Example:
  ```yaml
   - host: trino.example.com
     paths:
       - path: /
         pathType: ImplementationSpecific
  ```
* `ingress.tls` - list, default: `[]`  

  Ingress [TLS](https://kubernetes.io/docs/concepts/services-networking/ingress/#tls) configuration.
  Example:
  ```yaml
   - secretName: chart-example-tls
     hosts:
       - chart-example.local
  ```
* `resources.limits.cpu` - int, default: `2`
* `resources.limits.memory` - string, default: `"4Gi"`
* `resources.requests.cpu` - int, default: `2`
* `resources.requests.memory` - string, default: `"4Gi"`
* `autoscaling.enabled` - bool, default: `false`
* `autoscaling.minReplicas` - int, default: `1`
* `autoscaling.maxReplicas` - int, default: `100`
* `autoscaling.targetCPUUtilizationPercentage` - int, default: `80`  

  Target average CPU utilization, represented as a percentage of requested CPU. To disable scaling based on CPU, set to an empty string.
* `autoscaling.targetMemoryUtilizationPercentage` - string, default: `""`  

  Target average memory utilization, represented as a percentage of requested memory. To disable scaling based on memory, set to an empty string.
* `livenessProbe.initialDelaySeconds` - int, default: `30`
* `livenessProbe.periodSeconds` - int, default: `10`
* `livenessProbe.failureThreshold` - int, default: `3`
* `livenessProbe.timeoutSeconds` - int, default: `1`
* `livenessProbe.scheme` - string, default: `"HTTP"`
* `readinessProbe.initialDelaySeconds` - int, default: `5`
* `readinessProbe.periodSeconds` - int, default: `5`
* `readinessProbe.failureThreshold` - int, default: `12`
* `readinessProbe.timeoutSeconds` - int, default: `1`
* `readinessProbe.scheme` - string, default: `"HTTP"`
* `volumes` - list, default: `[]`
* `volumeMounts` - list, default: `[]`
* `lifecycle` - object, default: `{}`  

  Container lifecycle events.
  Example:
  ```yaml
   preStop:
     exec:
       command: ["/bin/sh", "-c", "sleep 120"]
  ```
* `terminationGracePeriodSeconds` - int, default: `30`
* `nodeSelector` - object, default: `{}`
* `tolerations` - list, default: `[]`
* `affinity` - object, default: `{}`
* `commonLabels` - object, default: `{}`  

  Labels that get applied to every resource's metadata
* `podAnnotations` - object, default: `{}`  

  Annotations to add to the Gateway pods.
  By default, all pods will have the `checksum/trino-gateway-config` annotation with the
  checksum of the current configuration file. This is used to trigger a rolling update of the deployment when the
  configuration changes. This behaviour can be disabled by manually setting this annotation to a fixed constant.
  Example:
  ```yaml
   podAnnotations:
     checksum/trino-gateway-config: ""
  ```
* `podLabels` - object, default: `{}`
* `podDisruptionBudget` - object, default: `{"minAvailable":1}`  

  [Pod Disruption Budget](https://kubernetes.io/docs/concepts/workloads/pods/disruptions/#pod-disruption-budgets) configuration.
* `podSecurityContext` - object, default: `{}`  

  [Pod security context](https://kubernetes.io/docs/tasks/configure-pod-container/security-context/#set-the-security-context-for-a-pod) configuration. To remove the default, set it to null (or `~`).
* `securityContext` - object, default: `{}`  

  [Container security context](https://kubernetes.io/docs/tasks/configure-pod-container/security-context/#set-the-security-context-for-a-container) configuration.
  Example:
  ```yaml
   capabilities:
     drop:
     - ALL
   readOnlyRootFilesystem: true
   runAsNonRoot: true
  ```
* `serviceAccount.create` - bool, default: `true`  

  Specifies whether a service account should be created
* `serviceAccount.automount` - bool, default: `true`  

  Automatically mount a ServiceAccount's API credentials?
* `serviceAccount.annotations` - object, default: `{}`  

  Annotations to add to the service account
* `serviceAccount.name` - string, default: `""`  

  The name of the service account to use. If not set and create is true, a name is generated using the fullname template
* `strategy` - object, default: `{"rollingUpdate":{"maxSurge":"25%","maxUnavailable":"25%"},"type":"RollingUpdate"}`  

  The deployment strategy to use to replace existing pods with new ones.

----------------------------------------------
Autogenerated from chart metadata using [helm-docs v1.14.2](https://github.com/norwoodj/helm-docs/releases/v1.14.2)
