# trino

![Version: 0.21.0](https://img.shields.io/badge/Version-0.21.0-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: 448](https://img.shields.io/badge/AppVersion-448-informational?style=flat-square)

Fast distributed SQL query engine for big data analytics that helps you explore your data universe

**Homepage:** <https://trino.io/>

## Source Code

* <https://github.com/trinodb/charts>
* <https://github.com/trinodb/trino/tree/master/core/docker>

## Values
* `image.registry` - string, default: `""`  

  Image registry, defaults to empty, which results in DockerHub usage
* `image.repository` - string, default: `"trinodb/trino"`  

  Repository location of the Trino image, typically `organization/imagename`
* `image.tag` - string, default: `""`  

  Image tag, defaults to the Trino release version specified as `appVersion` from Chart.yaml
* `image.digest` - string, default: `""`  

  Optional digest value of the image specified as `sha256:abcd...`. A specified value overrides `tag`.
* `image.useRepositoryAsSoleImageReference` - bool, default: `false`  

  When true, only the content in `repository` is used as image reference
* `image.pullPolicy` - string, default: `"IfNotPresent"`
* `imagePullSecrets[0].name` - string, default: `"registry-credentials"`
* `server.workers` - int, default: `2`
* `server.node.environment` - string, default: `"production"`
* `server.node.dataDir` - string, default: `"/data/trino"`
* `server.node.pluginDir` - string, default: `"/usr/lib/trino/plugin"`
* `server.log.trino.level` - string, default: `"INFO"`
* `server.config.path` - string, default: `"/etc/trino"`
* `server.config.http.port` - int, default: `8080`
* `server.config.https.enabled` - bool, default: `false`
* `server.config.https.port` - int, default: `8443`
* `server.config.https.keystore.path` - string, default: `""`
* `server.config.authenticationType` - string, default: `""`  

  Trino supports multiple [authentication types](https://trino.io/docs/current/security/authentication-types.html): PASSWORD, CERTIFICATE, OAUTH2, JWT, KERBEROS.
* `server.config.query.maxMemory` - string, default: `"4GB"`
* `server.exchangeManager.name` - string, default: `"filesystem"`
* `server.exchangeManager.baseDir` - string, default: `"/tmp/trino-local-file-system-exchange-manager"`
* `server.workerExtraConfig` - string, default: `""`
* `server.coordinatorExtraConfig` - string, default: `""`
* `server.autoscaling.enabled` - bool, default: `false`
* `server.autoscaling.maxReplicas` - int, default: `5`
* `server.autoscaling.targetCPUUtilizationPercentage` - int, default: `50`
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
* `accessControl` - object, default: `{}`  

  [System access control](https://trino.io/docs/current/security/built-in-system-access-control.html) configuration.
  Example:
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
* `resourceGroups` - object, default: `{}`  

  Resource groups file is mounted to /etc/trino/resource-groups/resource-groups.json
  Example:
  ```yaml
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
* `additionalNodeProperties` - object, default: `{}`
* `additionalConfigProperties` - object, default: `{}`
* `additionalLogProperties` - object, default: `{}`
* `additionalExchangeManagerProperties` - object, default: `{}`
* `eventListenerProperties` - object, default: `{}`
* `additionalCatalogs` - object, default: `{}`
* `env` - list, default: `[]`  

  additional environment variables added to every pod, specified as a list with explicit values
  Example:
  ```yaml
   - name: NAME
     value: "value"
  ```
* `envFrom` - list, default: `[]`  

  additional environment variables added to every pod, specified as a list of either ConfigMap or Secret references
  Example:
  ```yaml
    - secretRef:
      name: extra-secret
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
* `securityContext.runAsUser` - int, default: `1000`
* `securityContext.runAsGroup` - int, default: `1000`
* `containerSecurityContext` - object, default: `{"allowPrivilegeEscalation":false,"capabilities":{"drop":["ALL"]}}`  

  [Container security context](https://kubernetes.io/docs/tasks/configure-pod-container/security-context/#set-the-security-context-for-a-container) configuration.
* `containerSecurityContext.allowPrivilegeEscalation` - bool, default: `false`  

  Control whether a process can gain more privileges than its parent process.
* `containerSecurityContext.capabilities.drop` - list, default: `["ALL"]`  

  A list of the Linux kernel capabilities that are dropped from every container. Valid values are listed at https://man7.org/linux/man-pages/man7/capabilities.7.html Ensure to remove the "CAP_" prefix which the kernel attaches to the names of permissions.
* `shareProcessNamespace.coordinator` - bool, default: `false`
* `shareProcessNamespace.worker` - bool, default: `false`
* `service.type` - string, default: `"ClusterIP"`
* `service.port` - int, default: `8080`
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
* `serviceAccount.create` - bool, default: `false`  

  Specifies whether a service account should be created
* `serviceAccount.name` - string, default: `""`  

  The name of the service account to use. If not set and create is true, a name is generated using the fullname template
* `serviceAccount.annotations` - object, default: `{}`  

  Annotations to add to the service account
* `secretMounts` - list, default: `[]`  

  Allows mounting additional Trino configuration files from Kubernetes secrets on all nodes.
  Example:
  ```yaml
   - name: sample-secret
     secretName: sample-secret
     path: /secrets/sample.json
  ```
* `coordinator.jvm.maxHeapSize` - string, default: `"8G"`
* `coordinator.jvm.gcMethod.type` - string, default: `"UseG1GC"`
* `coordinator.jvm.gcMethod.g1.heapRegionSize` - string, default: `"32M"`
* `coordinator.config.memory.heapHeadroomPerNode` - string, default: `""`
* `coordinator.config.query.maxMemoryPerNode` - string, default: `"1GB"`
* `coordinator.additionalJVMConfig` - list, default: `[]`
* `coordinator.additionalExposedPorts` - object, default: `{}`
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
* `coordinator.lifecycle` - object, default: `{}`  

  Coordinator container [lifecycle events](https://kubernetes.io/docs/tasks/configure-pod-container/attach-handler-lifecycle-event/)
  Example:
  ```yaml
   preStop:
     exec:
       command: ["/bin/sh", "-c", "sleep 120"]
  ```
* `coordinator.terminationGracePeriodSeconds` - int, default: `30`
* `coordinator.nodeSelector` - object, default: `{}`
* `coordinator.tolerations` - list, default: `[]`
* `coordinator.affinity` - object, default: `{}`
* `coordinator.additionalConfigFiles` - object, default: `{}`
* `coordinator.additionalVolumes` - list, default: `[]`  

  One or more additional volumes to add to the coordinator.
  Example:
  ```yaml
   - name: extras
     emptyDir: {}
  ```
* `coordinator.additionalVolumeMounts` - list, default: `[]`  

  One or more additional volume mounts to add to the coordinator.
  Example:
   - name: extras
     mountPath: /usr/share/extras
     readOnly: true
* `coordinator.annotations` - object, default: `{}`
* `coordinator.labels` - object, default: `{}`
* `coordinator.secretMounts` - list, default: `[]`  

  Allows mounting additional Trino configuration files from Kubernetes secrets on the coordinator node.
  Example:
   - name: sample-secret
     secretName: sample-secret
     path: /secrets/sample.json
* `worker.jvm.maxHeapSize` - string, default: `"8G"`
* `worker.jvm.gcMethod.type` - string, default: `"UseG1GC"`
* `worker.jvm.gcMethod.g1.heapRegionSize` - string, default: `"32M"`
* `worker.config.memory.heapHeadroomPerNode` - string, default: `""`
* `worker.config.query.maxMemoryPerNode` - string, default: `"1GB"`
* `worker.additionalJVMConfig` - list, default: `[]`
* `worker.additionalExposedPorts` - object, default: `{}`
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
* `worker.lifecycle` - object, default: `{}`  

  To enable [graceful shutdown](https://trino.io/docs/current/admin/graceful-shutdown.html), define a lifecycle preStop like bellow, Set the `terminationGracePeriodSeconds` to a value greater than or equal to the configured `shutdown.grace-period`. Configure `shutdown.grace-period` in `additionalConfigProperties` as `shutdown.grace-period=2m` (default is 2 minutes). Also configure `accessControl` because the `default` system access control does not allow graceful shutdowns.
  Example:
  ```yaml
   preStop:
     exec:
       command: ["/bin/sh", "-c", "curl -v -X PUT -d '\"SHUTTING_DOWN\"' -H \"Content-type: application/json\" http://localhost:8081/v1/info/state"]
  ```
* `worker.terminationGracePeriodSeconds` - int, default: `30`
* `worker.nodeSelector` - object, default: `{}`
* `worker.tolerations` - list, default: `[]`
* `worker.affinity` - object, default: `{}`
* `worker.additionalConfigFiles` - object, default: `{}`
* `worker.additionalVolumes` - list, default: `[]`  

  One or more additional volume mounts to add to all workers.
  Example:
  ```yaml
   - name: extras
     emptyDir: {}
  ```
* `worker.additionalVolumeMounts` - list, default: `[]`  

  One or more additional volume mounts to add to all workers.
  Example:
  ```yaml
   - name: extras
     mountPath: /usr/share/extras
     readOnly: true
  ```
* `worker.annotations` - object, default: `{}`
* `worker.labels` - object, default: `{}`
* `worker.secretMounts` - list, default: `[]`  

  Allows mounting additional Trino configuration files from Kubernetes secrets on all worker nodes.
  Example:
  ```yaml
   - name: sample-secret
     secretName: sample-secret
     path: /secrets/sample.json
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
* `commonLabels` - object, default: `{}`  

  Labels that get applied to every resource's metadata
* `ingress.enabled` - bool, default: `false`
* `ingress.className` - string, default: `""`
* `ingress.annotations` - object, default: `{}`
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

----------------------------------------------
Autogenerated from chart metadata using [helm-docs v1.13.1](https://github.com/norwoodj/helm-docs/releases/v1.13.1)
