# trino

![Version: 1.37.0](https://img.shields.io/badge/Version-1.37.0-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: 470](https://img.shields.io/badge/AppVersion-470-informational?style=flat-square)

Fast distributed SQL query engine for big data analytics that helps you explore your data universe

**Homepage:** <https://trino.io/>

## Source Code

* <https://github.com/trinodb/charts>
* <https://github.com/trinodb/trino/tree/master/core/docker>

## Values
* `accessControl` - object, default: `{}`  

  [System access control](https://trino.io/docs/current/security/built-in-system-access-control.html) configuration.
  Set the type property to either:
  * `configmap`, and provide the rule file contents in `rules`,
  * `properties`, and provide configuration properties in `properties`.
  Properties example:
  ```yaml
  type: properties
  properties: |
      access-control.name=custom-access-control
      access-control.custom_key=custom_value
  ```
  Config map example:
  ```yaml
   type: configmap
   refreshPeriod: 60s
   # Rules file is mounted to /etc/trino/access-control
   configFile: "rules.json"
   rules:
     rules.json: |-
       {
         "catalogs": [
           {
             "user": "admin",
             "catalog": "(mysql|system)",
             "allow": "all"
           },
           {
             "group": "finance|human_resources",
             "catalog": "postgres",
             "allow": true
           },
           {
             "catalog": "hive",
             "allow": "all"
           },
           {
             "user": "alice",
             "catalog": "postgresql",
             "allow": "read-only"
           },
           {
             "catalog": "system",
             "allow": "none"
           }
         ],
         "schemas": [
           {
             "user": "admin",
             "schema": ".*",
             "owner": true
           },
           {
             "user": "guest",
             "owner": false
           },
           {
             "catalog": "default",
             "schema": "default",
             "owner": true
           }
         ]
       }
  ```
* `additionalCatalogs` - object, default: `{}`  

  Deprecated, use `catalogs` instead. Configure additional [catalogs](https://trino.io/docs/current/installation/deployment.html#catalog-properties).
* `additionalConfigProperties` - list, default: `[]`  

  [Additional config properties](https://trino.io/docs/current/admin/properties.html).
  Example:
  ```yaml
   - internal-communication.shared-secret=random-value-999
   - http-server.process-forwarded=true
  ```
* `additionalExchangeManagerProperties` - list, default: `[]`  

  [Exchange manager properties](https://trino.io/docs/current/admin/fault-tolerant-execution.html#exchange-manager).
  Example:
  ```yaml
   - exchange.s3.region=object-store-region
   - exchange.s3.endpoint=your-object-store-endpoint
   - exchange.s3.aws-access-key=your-access-key
   - exchange.s3.aws-secret-key=your-secret-key
  ```
* `additionalLogProperties` - list, default: `[]`  

  [Additional log properties](https://trino.io/docs/current/installation/deployment.html#log-levels).
  Example:
  ```yaml
   - io.airlift=DEBUG
  ```
* `additionalNodeProperties` - list, default: `[]`  

  [Additional node properties](https://trino.io/docs/current/installation/deployment.html#log-levels).
  Example, assuming the NODE_ID environment variable has been set:
  ```yaml
   - node.id=${NODE_ID}
  ```
* `auth` - object, default: `{}`  

  Available authentication methods.
  Use username and password provided as a [password file](https://trino.io/docs/current/security/password-file.html#file-format):
  ```yaml
   passwordAuth: "username:encrypted-password-with-htpasswd"
  ```
  Set the name of a secret containing this file in the password.db key
  ```yaml
   passwordAuthSecret: "trino-password-authentication"
  ```
  Additionally, set [users' groups](https://trino.io/docs/current/security/group-file.html#file-format):
  ```yaml
   refreshPeriod: 5s
   groups: "group_name:user_1,user_2,user_3"
  ```
  Set the name of a secret containing this file in the group.db key
  ```yaml
   groupAuthSecret: "trino-group-authentication"
  ```
* `catalogs` - object, default: `{"tpcds":"connector.name=tpcds\ntpcds.splits-per-node=4\n","tpch":"connector.name=tpch\ntpch.splits-per-node=4\n"}`  

  Configure [catalogs](https://trino.io/docs/current/installation/deployment.html#catalog-properties).
  Example:
  ```yaml
   objectstore: |
     connector.name=iceberg
     iceberg.catalog.type=glue
   jmx: |
     connector.name=memory
   memory: |
     connector.name=memory
     memory.max-data-per-node=128MB
  ```
* `catalogsSecrets` - list, default: `[]`
* `commonLabels` - object, default: `{}`  

  Labels that get applied to every resource's metadata
* `configMounts` - list, default: `[]`  

  Allows mounting additional Trino configuration files from Kubernetes config maps on all nodes.
  Example:
  ```yaml
   - name: sample-config-mount
     configMap: sample-config-map
     path: /config-map/sample.json
     subPath: sample.json
  ```
* `containerSecurityContext` - object, default: `{"allowPrivilegeEscalation":false,"capabilities":{"drop":["ALL"]}}`  

  [Container security context](https://kubernetes.io/docs/tasks/configure-pod-container/security-context/#set-the-security-context-for-a-container) configuration.
* `containerSecurityContext.allowPrivilegeEscalation` - bool, default: `false`  

  Control whether a process can gain more privileges than its parent process.
* `containerSecurityContext.capabilities.drop` - list, default: `["ALL"]`  

  A list of the Linux kernel capabilities that are dropped from every container. Valid values are listed in [the capabilities manual page](https://man7.org/linux/man-pages/man7/capabilities.7.html). Ensure # to remove the "CAP_" prefix which the kernel attaches to the names of permissions.
* `coordinator.additionalConfigFiles` - object, default: `{}`  

  Additional config files placed in the default configuration directory. Supports templating the files' contents with `tpl`.
  Example:
  ```yaml
  secret.txt: |
    secret-value={{- .Values.someValue }}
  ```
* `coordinator.additionalExposedPorts` - object, default: `{}`  

  Additional ports configured in the coordinator container and the service.
  Example:
  ```yaml
   https:
     servicePort: 8443
     name: https
     port: 8443
     nodePort: 30443
     protocol: TCP
  ```
* `coordinator.additionalJVMConfig` - list, default: `[]`
* `coordinator.additionalVolumeMounts` - list, default: `[]`  

  One or more additional volume mounts to add to the coordinator.
  Example:
   - name: extras
     mountPath: /usr/share/extras
     readOnly: true
* `coordinator.additionalVolumes` - list, default: `[]`  

  One or more additional volumes to add to the coordinator.
  Example:
  ```yaml
   - name: extras
     emptyDir: {}
  ```
* `coordinator.affinity` - object, default: `{}`
* `coordinator.annotations` - object, default: `{}`
* `coordinator.config.memory.heapHeadroomPerNode` - string, default: `""`
* `coordinator.config.nodeScheduler.includeCoordinator` - bool, default: `false`  

  Allows scheduling work on the coordinator so that a single machine can function as both coordinator and worker. For large clusters, processing work on the coordinator can negatively impact query performance because the machine's resources are not available for the critical coordinator tasks of scheduling, managing, and monitoring query execution.
* `coordinator.config.query.maxMemoryPerNode` - string, default: `"1GB"`
* `coordinator.configMounts` - list, default: `[]`  

  Allows mounting additional Trino configuration files from Kubernetes config maps on the coordinator node.
  Example:
  ```yaml
   - name: sample-config-mount
     configMap: sample-config-mount
     path: /config-mount/sample.json
     subPath: sample.json
  ```
* `coordinator.deployment.annotations` - object, default: `{}`
* `coordinator.deployment.progressDeadlineSeconds` - int, default: `600`  

  The maximum time in seconds for a deployment to make progress before it is considered failed. The deployment controller continues to process failed deployments and a condition with a ProgressDeadlineExceeded reason is surfaced in the deployment status.
* `coordinator.deployment.revisionHistoryLimit` - int, default: `10`  

  The number of old ReplicaSets to retain to allow rollback.
* `coordinator.deployment.strategy` - object, default: `{"rollingUpdate":{"maxSurge":"25%","maxUnavailable":"25%"},"type":"RollingUpdate"}`  

  The deployment strategy to use to replace existing pods with new ones.
* `coordinator.jvm.gcMethod.g1.heapRegionSize` - string, default: `"32M"`
* `coordinator.jvm.gcMethod.type` - string, default: `"UseG1GC"`
* `coordinator.jvm.maxHeapSize` - string, default: `"8G"`
* `coordinator.labels` - object, default: `{}`
* `coordinator.lifecycle` - object, default: `{}`  

  Coordinator container [lifecycle events](https://kubernetes.io/docs/tasks/configure-pod-container/attach-handler-lifecycle-event/)
  Example:
  ```yaml
   preStop:
     exec:
       command: ["/bin/sh", "-c", "sleep 120"]
  ```
* `coordinator.livenessProbe` - object, default: `{}`  

  [Liveness probe](https://kubernetes.io/docs/tasks/configure-pod-container/configure-liveness-readiness-startup-probes/#configure-probes) options
  Example:
  ```yaml
   initialDelaySeconds: 20
   periodSeconds: 10
   timeoutSeconds: 5
   failureThreshold: 6
   successThreshold: 1
  ```
* `coordinator.nodeSelector` - object, default: `{}`
* `coordinator.readinessProbe` - object, default: `{}`  

  [Readiness probe](https://kubernetes.io/docs/tasks/configure-pod-container/configure-liveness-readiness-startup-probes/#configure-probes)
  Example:
  ```yaml
   initialDelaySeconds: 20
   periodSeconds: 10
   timeoutSeconds: 5
   failureThreshold: 6
   successThreshold: 1
  ```
* `coordinator.resources` - object, default: `{}`  

  It is recommended not to specify default resources and to leave this as a conscious choice for the user. This also increases chances charts run on environments with little resources, such as Minikube. If you do want to specify resources, use the following example, and adjust it as necessary.
  Example:
  ```yaml
   limits:
     cpu: 100m
     memory: 128Mi
   requests:
     cpu: 100m
     memory: 128Mi
  ```
* `coordinator.secretMounts` - list, default: `[]`  

  Allows mounting additional Trino configuration files from Kubernetes secrets on the coordinator node.
  Example:
  ```yaml
   - name: sample-secret
     secretName: sample-secret
     path: /secrets/sample.json
     subPath: sample.json
  ```
* `coordinator.terminationGracePeriodSeconds` - int, default: `30`
* `coordinator.tolerations` - list, default: `[]`
* `coordinatorNameOverride` - string, default: `nil`
* `env` - list, default: `[]`  

  additional environment variables added to every pod, specified as a list with explicit values
  Example:
  ```yaml
   - name: NAME
     value: "value"
  ```
* `envFrom` - list, default: `[]`  

  additional environment variables added to every pod, specified as a list of either `ConfigMap` or `Secret` references
  Example:
  ```yaml
    - secretRef:
      name: extra-secret
  ```
* `eventListenerProperties` - list, default: `[]`  

  [Event listener](https://trino.io/docs/current/develop/event-listener.html#event-listener) properties. To configure multiple event listeners, add them in `coordinator.additionalConfigFiles` and `worker.additionalConfigFiles`, and set the `event-listener.config-files` property in `additionalConfigProperties` to their locations.
  Example:
  ```yaml
   - event-listener.name=custom-event-listener
   - custom-property1=custom-value1
   - custom-property2=custom-value2
  ```
* `image.digest` - string, default: `""`  

  Optional digest value of the image specified as `sha256:abcd...`. A specified value overrides `tag`.
* `image.pullPolicy` - string, default: `"IfNotPresent"`
* `image.registry` - string, default: `""`  

  Image registry, defaults to empty, which results in DockerHub usage
* `image.repository` - string, default: `"trinodb/trino"`  

  Repository location of the Trino image, typically `organization/imagename`
* `image.tag` - string, default: `""`  

  Image tag, defaults to the Trino release version specified as `appVersion` from Chart.yaml
* `image.useRepositoryAsSoleImageReference` - bool, default: `false`  

  When true, only the content in `repository` is used as image reference
* `imagePullSecrets` - list, default: `[]`  

  An optional list of references to secrets in the same namespace to use for pulling images.
  Example:
  ```yaml
  imagePullSecrets:
    - name: registry-credentials
  ```
* `ingress.annotations` - object, default: `{}`
* `ingress.className` - string, default: `""`
* `ingress.enabled` - bool, default: `false`
* `ingress.hosts` - list, default: `[]`  

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
* `initContainers` - object, default: `{}`  

  Additional [containers that run to completion](https://kubernetes.io/docs/concepts/workloads/pods/init-containers/) during pod initialization.
  Example:
  ```yaml
   coordinator:
     - name: init-coordinator
       image: busybox:1.28
       imagePullPolicy: IfNotPresent
       command: ['sh', '-c', "until nslookup myservice.$(cat /var/run/secrets/kubernetes.io/serviceaccount/namespace).svc.cluster.local; do echo waiting for myservice; sleep 2; done"]
   worker:
     - name: init-worker
       image: busybox:1.28
       command: ['sh', '-c', 'echo The worker is running! && sleep 3600']
  ```
* `jmx.coordinator` - object, default: `{}`  

  Override JMX configurations for the Trino coordinator.
  Example
  ```yaml
  coordinator:
    enabled: true
    exporter:
      enabled: true
      configProperties: |-
        hostPort: localhost:{{- .Values.jmx.registryPort }}
        startDelaySeconds: 0
        ssl: false
  ```
* `jmx.enabled` - bool, default: `false`  

  Set to true to enable the RMI server to expose Trino's [JMX metrics](https://trino.io/docs/current/admin/jmx.html).
* `jmx.exporter.configProperties` - string, default: `""`  

  The string value is templated using `tpl`. The JMX config properties file is mounted to `/etc/jmx-exporter/jmx-exporter-config.yaml`.
  Example:
  ```yaml
   configProperties: |-
      hostPort: localhost:{{- .Values.jmx.registryPort }}
      startDelaySeconds: 0
      ssl: false
      lowercaseOutputName: false
      lowercaseOutputLabelNames: false
      includeObjectNames: ["java.lang:type=Threading"]
      autoExcludeObjectNameAttributes: true
      excludeObjectNameAttributes:
        "java.lang:type=OperatingSystem":
          - "ObjectName"
        "java.lang:type=Runtime":
          - "ClassPath"
          - "SystemProperties"
      rules:
        - pattern: 'java\.lang<type=Threading><(.*)>ThreadCount: (.*)'
          name: java_lang_Threading_ThreadCount
          value: '$2'
          help: 'ThreadCount (java.lang<type=Threading><>ThreadCount)'
          type: UNTYPED
  ```
* `jmx.exporter.enabled` - bool, default: `false`  

  Set to true to export JMX Metrics via HTTP for [Prometheus](https://github.com/prometheus/jmx_exporter) consumption
* `jmx.exporter.image` - string, default: `"bitnami/jmx-exporter:1.0.1"`
* `jmx.exporter.port` - int, default: `5556`
* `jmx.exporter.pullPolicy` - string, default: `"Always"`
* `jmx.exporter.resources` - object, default: `{}`  

  It is recommended not to specify default resources and to leave this as a conscious choice for the user. This also increases chances charts run on environments with little resources, such as Minikube. If you do want to specify resources, use the following example, and adjust it as necessary.
  Example:
  ```yaml
   limits:
     cpu: 100m
     memory: 128Mi
   requests:
     cpu: 100m
     memory: 128Mi
  ```
* `jmx.exporter.securityContext` - object, default: `{}`
* `jmx.registryPort` - int, default: `9080`
* `jmx.serverPort` - int, default: `9081`
* `jmx.worker` - object, default: `{}`  

  Override JMX configurations for the Trino workers.
  Example
  ```yaml
  worker:
    enabled: true
    exporter:
      enabled: true
  ```
* `kafka.mountPath` - string, default: `"/etc/trino/schemas"`
* `kafka.tableDescriptions` - object, default: `{}`  

  Custom kafka table descriptions that will be mounted in mountPath.
  Example:
  ```yaml
   testschema.json: |-
     {
       "tableName": "testtable",
       "schemaName": "testschema",
       "topicName": "testtopic",
       "key": {
         "dataFormat": "json",
         "fields": [
           {
             "name": "_key",
             "dataFormat": "VARCHAR",
             "type": "VARCHAR",
             "hidden": "false"
           }
         ]
       },
       "message": {
         "dataFormat": "json",
         "fields": [
           {
             "name": "id",
             "mapping": "id",
             "type": "BIGINT"
           },
           {
             "name": "test_field",
             "mapping": "test_field",
             "type": "VARCHAR"
           }
         ]
       }
     }
  ```
* `ldapSecrets` - list, default: `[]`
* `nameOverride` - string, default: `nil`  

  Override resource names to avoid name conflicts when deploying multiple releases in the same namespace.
  Example:
  ```yaml
  coordinatorNameOverride: trino-coordinator-adhoc
  workerNameOverride: trino-worker-adhoc
  nameOverride: trino-adhoc
  ```
* `networkPolicy.egress` - list, default: `[]`  

  Egress rules to apply to the Trino pods.
  Example:
  ```yaml
   - to:
       - podSelector:
           matchLabels:
             role: log-ingestor
     ports:
       - protocol: TCP
         port: 9999
  ```
* `networkPolicy.enabled` - bool, default: `false`  

  Set to true to enable Trino pod protection with a [NetworkPolicy](https://kubernetes.io/docs/concepts/services-networking/network-policies/). By default, the NetworkPolicy will only allow Trino pods to communicate with each other.
  > [!NOTE]
  > - NetworkPolicies cannot block the ingress traffic coming directly
  > from the Kubernetes node on which the Pod is running,
  > and are thus incompatible with services of type `NodePort`.
  > - When using NetworkPolicies together with JMX metrics export,
  > additional ingress rules might be required to allow metric scraping.
* `networkPolicy.ingress` - list, default: `[]`  

  Additional ingress rules to apply to the Trino pods.
  Example:
  ```yaml
   - from:
       - ipBlock:
           cidr: 172.17.0.0/16
           except:
             - 172.17.1.0/24
       - namespaceSelector:
           matchLabels:
             kubernetes.io/metadata.name: prometheus
       - podSelector:
           matchLabels:
             role: backend-app
     ports:
       - protocol: TCP
         port: 8080
       - protocol: TCP
         port: 5556
  ```
* `resourceGroups` - object, default: `{}`  

  [Resource groups control](https://trino.io/docs/current/admin/resource-groups.html)
  Set the type property to either:
  * `configmap`, and provide the Resource groups file contents in `resourceGroupsConfig`,
  * `properties`, and provide configuration properties in `properties`.
  Properties example:
  ```yaml
   type: properties
   properties: |
     resource-groups.configuration-manager=db
     resource-groups.config-db-url=jdbc:postgresql://trino-postgresql.postgresql.svc.cluster.local:3306/resource_groups
     resource-groups.config-db-user=username
     resource-groups.config-db-password=password
  ```
  Config map example:
  ```yaml
   type: configmap
   # Resource groups file is mounted to /etc/trino/resource-groups/resource-groups.json
   resourceGroupsConfig: |-
       {
         "rootGroups": [
           {
             "name": "global",
             "softMemoryLimit": "80%",
             "hardConcurrencyLimit": 100,
             "maxQueued": 100,
             "schedulingPolicy": "fair",
             "jmxExport": true,
             "subGroups": [
               {
                 "name": "admin",
                 "softMemoryLimit": "30%",
                 "hardConcurrencyLimit": 20,
                 "maxQueued": 10
               },
               {
                 "name": "finance_human_resources",
                 "softMemoryLimit": "20%",
                 "hardConcurrencyLimit": 15,
                 "maxQueued": 10
               },
               {
                 "name": "general",
                 "softMemoryLimit": "30%",
                 "hardConcurrencyLimit": 20,
                 "maxQueued": 10
               },
               {
                 "name": "readonly",
                 "softMemoryLimit": "10%",
                 "hardConcurrencyLimit": 5,
                 "maxQueued": 5
               }
             ]
           }
         ],
         "selectors": [
           {
             "user": "admin",
             "group": "global.admin"
           },
           {
             "group": "finance|human_resources",
             "group": "global.finance_human_resources"
           },
           {
             "user": "alice",
             "group": "global.readonly"
           },
           {
             "group": "global.general"
           }
         ]
       }
  ```
* `secretMounts` - list, default: `[]`  

  Allows mounting additional Trino configuration files from Kubernetes secrets on all nodes.
  Example:
  ```yaml
   - name: sample-secret
     secretName: sample-secret
     path: /secrets/sample.json
     subPath: sample.json
   - name: catalogs
     secretName: catalogs
     path: /etc/trino/catalog
   - name: ldap
     secretName: ldap
     path: /etc/trino/ldap
  ```
* `securityContext` - object, default: `{"runAsGroup":1000,"runAsUser":1000}`  

  [Pod security context](https://kubernetes.io/docs/tasks/configure-pod-container/security-context/#set-the-security-context-for-a-pod) configuration. To remove the default, set it to null (or `~`).
* `server.autoscaling` - object, default: `{"behavior":{},"enabled":false,"maxReplicas":5,"targetCPUUtilizationPercentage":50,"targetMemoryUtilizationPercentage":80}`  

  Configure [Horizontal Pod Autoscaling](https://kubernetes.io/docs/tasks/run-application/horizontal-pod-autoscale/) for workers (`server.keda.enabled` must be `false`).
* `server.autoscaling.behavior` - object, default: `{}`  

  Configuration for scaling up and down.
  Example:
  ```yaml
   scaleDown:
     stabilizationWindowSeconds: 300
     policies:
     - type: Percent
       value: 100
       periodSeconds: 15
   scaleUp:
     stabilizationWindowSeconds: 0
     policies:
     - type: Percent
       value: 100
       periodSeconds: 15
     - type: Pods
       value: 4
       periodSeconds: 15
     selectPolicy: Max
  ```
* `server.autoscaling.targetCPUUtilizationPercentage` - int, default: `50`  

  Target average CPU utilization, represented as a percentage of requested CPU. To disable scaling based on CPU, set to an empty string.
* `server.autoscaling.targetMemoryUtilizationPercentage` - int, default: `80`  

  Target average memory utilization, represented as a percentage of requested memory. To disable scaling based on memory, set to an empty string.
* `server.config.authenticationType` - string, default: `""`  

  Trino supports multiple [authentication types](https://trino.io/docs/current/security/authentication-types.html): PASSWORD, CERTIFICATE, OAUTH2, JWT, KERBEROS.
* `server.config.https.enabled` - bool, default: `false`
* `server.config.https.keystore.path` - string, default: `""`
* `server.config.https.port` - int, default: `8443`
* `server.config.path` - string, default: `"/etc/trino"`
* `server.config.query.maxMemory` - string, default: `"4GB"`
* `server.coordinatorExtraConfig` - string, default: `""`
* `server.exchangeManager` - object, default: `{}`  

  Mandatory [exchange manager configuration](https://trino.io/docs/current/admin/fault-tolerant-execution.html#id1). Used to set the name and location(s) of spooling data storage. For multiple destinations use a list or a comma separated URI locations. To enable fault-tolerant execution, set the `retry-policy` property in `additionalConfigProperties`. Additional exchange manager configurations can be added to `additionalExchangeManagerProperties`.
  Example:
  ```yaml
  server:
    exchangeManager:
      name: "filesystem"
      baseDir:
        - "/tmp/trino-local-file-system-exchange-manager"
  additionalConfigProperties:
    - retry-policy=TASK
  additionalExchangeManagerProperties:
    - exchange.sink-buffer-pool-min-size=10
    - exchange.sink-buffers-per-partition=2
    - exchange.source-concurrent-readers=4
  ```
* `server.keda` - object, default: `{"advanced":{},"annotations":{},"cooldownPeriod":300,"enabled":false,"fallback":{},"initialCooldownPeriod":0,"maxReplicaCount":5,"minReplicaCount":0,"pollingInterval":30,"triggers":[]}`  

  Configure [Kubernetes Event-driven Autoscaling](https://keda.sh/) for workers (`server.autoscaling.enabled` must be `false`).
* `server.keda.advanced` - object, default: `{}`  

  Specifies HPA related options
  Example:
  ```yaml
  advanced:
    horizontalPodAutoscalerConfig:
      behavior:
        scaleDown:
          stabilizationWindowSeconds: 300
          policies:
            - type: Percent
              value: 100
              periodSeconds: 15
  ```
* `server.keda.annotations` - object, default: `{}`  

  Annotations to apply to the ScaledObject CRD.
  Example:
  ```yaml
  annotations:
    autoscaling.keda.sh/paused-replicas: "0"
    autoscaling.keda.sh/paused: "true"
  ```
* `server.keda.cooldownPeriod` - int, default: `300`  

  Period (in seconds) to wait after the last trigger reported active before scaling the resource back to 0
* `server.keda.fallback` - object, default: `{}`  

  Defines a number of replicas to fall back to if a scaler is in an error state.
  Example:
  ```yaml
  fallback:             # Optional. Section to specify fallback options
    failureThreshold: 3 # Mandatory if fallback section is included
    replicas: 6         # Mandatory if fallback section is included
  ```
* `server.keda.initialCooldownPeriod` - int, default: `0`  

  The delay (in seconds) before the `cooldownPeriod` starts after the initial creation of the `ScaledObject`.
* `server.keda.maxReplicaCount` - int, default: `5`  

  This setting is passed to the HPA definition that KEDA will create for a given resource and holds the maximum number of replicas of the target resource.
* `server.keda.minReplicaCount` - int, default: `0`  

  Minimum number of replicas KEDA will scale the resource down to. By default, it’s scale to zero, but you can use it with some other value as well.
* `server.keda.triggers` - list, default: `[]`  

  List of triggers to activate scaling of the target resource
  Example:
  ```yaml
  triggers:
    - type: prometheus
      metricType: Value
      metadata:
        serverAddress: "http://prometheus.example.com"
        threshold: "1"
        metricName: required_workers
          query: >-
            sum by (service)
            (avg_over_time(trino_execution_ClusterSizeMonitor_RequiredWorkers{service={{ include "trino.fullname" . | quote }}}[5s]))
  ```
* `server.log.trino.level` - string, default: `"INFO"`
* `server.node.dataDir` - string, default: `"/data/trino"`
* `server.node.environment` - string, default: `"production"`
* `server.node.pluginDir` - string, default: `"/usr/lib/trino/plugin"`
* `server.workerExtraConfig` - string, default: `""`
* `server.workers` - int, default: `2`
* `service.annotations` - object, default: `{}`
* `service.nodePort` - string, default: `""`  

  The port the service listens on the host, for the `NodePort` type. If not set, Kubernetes will [allocate a port automatically](https://kubernetes.io/docs/concepts/services-networking/service/#nodeport-custom-port).
* `service.port` - int, default: `8080`
* `service.type` - string, default: `"ClusterIP"`
* `serviceAccount.annotations` - object, default: `{}`  

  Annotations to add to the service account
* `serviceAccount.create` - bool, default: `false`  

  Specifies whether a service account should be created
* `serviceAccount.name` - string, default: `""`  

  The name of the service account to use. If not set and create is true, a name is generated using the fullname template
* `serviceMonitor.apiVersion` - string, default: `"monitoring.coreos.com/v1"`
* `serviceMonitor.coordinator` - object, default: `{}`  

  Override ServiceMonitor configurations for the Trino coordinator.
  Example
  ```yaml
  coordinator:
    enabled: true
    labels:
      prometheus: my-prometheus
  ```
* `serviceMonitor.enabled` - bool, default: `false`  

  Set to true to create resources for the [prometheus-operator](https://github.com/prometheus-operator/prometheus-operator).
* `serviceMonitor.interval` - string, default: `"30s"`  

  The serviceMonitor web endpoint interval
* `serviceMonitor.labels` - object, default: `{"prometheus":"kube-prometheus"}`  

  Labels for serviceMonitor, so that Prometheus can select it
* `serviceMonitor.worker` - object, default: `{}`  

  Override ServiceMonitor configurations for the Trino workers.
  Example
  ```yaml
  worker:
    enabled: true
    labels:
      prometheus: my-prometheus
  ```
* `shareProcessNamespace.coordinator` - bool, default: `false`
* `shareProcessNamespace.worker` - bool, default: `false`
* `sidecarContainers` - object, default: `{}`  

  Additional [containers that starts before](https://kubernetes.io/docs/concepts/workloads/pods/sidecar-containers/) the Trino container and continues to run.
  Example:
  ```yaml
   coordinator:
     - name: side-coordinator
       image: busybox:1.28
       imagePullPolicy: IfNotPresent
       command: ['sleep', '1']
   worker:
     - name: side-worker
       image: busybox:1.28
       imagePullPolicy: IfNotPresent
       command: ['sleep', '1']
  ```
* `worker.additionalConfigFiles` - object, default: `{}`  

  Additional config files placed in the default configuration directory. Supports templating the files' contents with `tpl`.
  Example:
  ```yaml
  secret.txt: |
    secret-value={{- .Values.someValue }}
  ```
* `worker.additionalExposedPorts` - object, default: `{}`  

  Additional container ports configured in all worker pods.
  Example:
  ```yaml
   https:
     servicePort: 8443
     name: https
     port: 8443
     protocol: TCP
  ```
* `worker.additionalJVMConfig` - list, default: `[]`
* `worker.additionalVolumeMounts` - list, default: `[]`  

  One or more additional volume mounts to add to all workers.
  Example:
  ```yaml
   - name: extras
     mountPath: /usr/share/extras
     readOnly: true
  ```
* `worker.additionalVolumes` - list, default: `[]`  

  One or more additional volume mounts to add to all workers.
  Example:
  ```yaml
   - name: extras
     emptyDir: {}
  ```
* `worker.affinity` - object, default: `{}`
* `worker.annotations` - object, default: `{}`
* `worker.config.memory.heapHeadroomPerNode` - string, default: `""`
* `worker.config.query.maxMemoryPerNode` - string, default: `"1GB"`
* `worker.configMounts` - list, default: `[]`  

  Allows mounting additional Trino configuration files from Kubernetes config maps on all worker nodes.
  Example:
  ```yaml
  - name: sample-config-mount
    configMap: sample-config-mount
    path: /config-mount/sample.json
    subPath: sample.json
  ```
* `worker.deployment.annotations` - object, default: `{}`
* `worker.deployment.progressDeadlineSeconds` - int, default: `600`  

  The maximum time in seconds for a deployment to make progress before it is considered failed. The deployment controller continues to process failed deployments and a condition with a ProgressDeadlineExceeded reason is surfaced in the deployment status.
* `worker.deployment.revisionHistoryLimit` - int, default: `10`  

  The number of old ReplicaSets to retain to allow rollback.
* `worker.deployment.strategy` - object, default: `{"rollingUpdate":{"maxSurge":"25%","maxUnavailable":"25%"},"type":"RollingUpdate"}`  

  The deployment strategy to use to replace existing pods with new ones.
* `worker.gracefulShutdown` - object, default: `{"enabled":false,"gracePeriodSeconds":120}`  

  Configure [graceful shutdown](https://trino.io/docs/current/admin/graceful-shutdown.html) in order to ensure that workers terminate without affecting running queries, given a sufficient grace period. When enabled, the value of `worker.terminationGracePeriodSeconds` must be at least two times greater than the configured `gracePeriodSeconds`. Enabling `worker.gracefulShutdown` conflicts with `worker.lifecycle`. When a custom `worker.lifecycle` configuration needs to be used, graceful shutdown must be configured manually.
  Example:
  ```yaml
   gracefulShutdown:
     enabled: true
     gracePeriodSeconds: 120
  ```
* `worker.jvm.gcMethod.g1.heapRegionSize` - string, default: `"32M"`
* `worker.jvm.gcMethod.type` - string, default: `"UseG1GC"`
* `worker.jvm.maxHeapSize` - string, default: `"8G"`
* `worker.labels` - object, default: `{}`
* `worker.lifecycle` - object, default: `{}`  

  Worker container [lifecycle events](https://kubernetes.io/docs/tasks/configure-pod-container/attach-handler-lifecycle-event/)  Setting `worker.lifecycle` conflicts with `worker.gracefulShutdown`.
  Example:
  ```yaml
   preStop:
     exec:
       command: ["/bin/sh", "-c", "sleep 120"]
  ```
* `worker.livenessProbe` - object, default: `{}`  

  [Liveness probe](https://kubernetes.io/docs/tasks/configure-pod-container/configure-liveness-readiness-startup-probes/#configure-probes)
  Example:
  ```yaml
   initialDelaySeconds: 20
   periodSeconds: 10
   timeoutSeconds: 5
   failureThreshold: 6
   successThreshold: 1
  ```
* `worker.nodeSelector` - object, default: `{}`
* `worker.readinessProbe` - object, default: `{}`  

  [Readiness probe](https://kubernetes.io/docs/tasks/configure-pod-container/configure-liveness-readiness-startup-probes/#configure-probes)
  Example:
  ```yaml
   initialDelaySeconds: 20
   periodSeconds: 10
   timeoutSeconds: 5
   failureThreshold: 6
   successThreshold: 1
  ```
* `worker.resources` - object, default: `{}`  

  It is recommended not to specify default resources and to leave this as a conscious choice for the user. This also increases chances charts run on environments with little resources, such as Minikube. If you do want to specify resources, use the following example, and adjust it as necessary.
  Example:
  ```yaml
   limits:
     cpu: 100m
     memory: 128Mi
   requests:
     cpu: 100m
     memory: 128Mi
  ```
* `worker.secretMounts` - list, default: `[]`  

  Allows mounting additional Trino configuration files from Kubernetes secrets on all worker nodes.
  Example:
  ```yaml
   - name: sample-secret
     secretName: sample-secret
     path: /secrets/sample.json
     subPath: sample.json
  ```
* `worker.terminationGracePeriodSeconds` - int, default: `30`
* `worker.tolerations` - list, default: `[]`
* `workerNameOverride` - string, default: `nil`

----------------------------------------------
Autogenerated from chart metadata using [helm-docs v1.14.2](https://github.com/norwoodj/helm-docs/releases/v1.14.2)
