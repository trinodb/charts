# trino

![Version: 1.44.0](https://img.shields.io/badge/Version-1.44.0-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: 483](https://img.shields.io/badge/AppVersion-483-informational?style=flat-square)

Fast distributed SQL query engine for big data analytics that helps you explore your data universe

**Homepage:** <https://trino.io/>

## Source Code

* <https://github.com/trinodb/charts>
* <https://github.com/trinodb/trino/tree/master/core/docker>

## Values
* `nameOverride` - string, default: `nil`  

  Override resource names to avoid name conflicts when deploying multiple releases in the same namespace.
  Example:
  ```yaml
  coordinatorNameOverride: trino-coordinator-adhoc
  workerNameOverride: trino-worker-adhoc
  nameOverride: trino-adhoc
  fullnameOverride: trino-adhoc
  ```
* `fullnameOverride` - string, default: `nil`
* `coordinatorNameOverride` - string, default: `nil`
* `workerNameOverride` - string, default: `nil`
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
* `imagePullSecrets` - list, default: `[]`  

  An optional list of references to secrets in the same namespace to use for pulling images.
  Example:
  ```yaml
  imagePullSecrets:
    - name: registry-credentials
  ```
* `testImages` - object, default: `{"kubectl":{"pullPolicy":"IfNotPresent","repository":"alpine/kubectl","tag":"1.37.1"},"postgresql":{"pullPolicy":"IfNotPresent","repository":"postgres","tag":"18-alpine"},"python":{"pullPolicy":"IfNotPresent","repository":"python","tag":"3-slim"}}`  

  Images of the containers the chart's [Helm tests](https://helm.sh/docs/topics/chart_tests/) run, so a cluster that pulls through a mirror can run them too. The registry prefix is shared with the Trino image and comes from `image.registry`.
* `testImages.kubectl` - object, default: `{"pullPolicy":"IfNotPresent","repository":"alpine/kubectl","tag":"1.37.1"}`  

  Used by the graceful shutdown test to watch and delete a worker pod. It needs a shell, so a distroless image such as `registry.k8s.io/kubectl` does not work here.
* `testImages.postgresql` - object, default: `{"pullPolicy":"IfNotPresent","repository":"postgres","tag":"18-alpine"}`  

  Used by the connection test to seed the resource groups database, so it is only pulled when `resourceGroups.type` is `properties`.
* `testImages.python` - object, default: `{"pullPolicy":"IfNotPresent","repository":"python","tag":"3-slim"}`  

  Used by the JMX test to query the Prometheus targets the ServiceMonitor produced.
* `server.workers` - int, default: `2`
* `server.node.environment` - string, default: `"production"`  

  Supports templating with `tpl`.
* `server.node.dataDir` - string, default: `"/data/trino"`
* `server.node.pluginDir` - string, default: `"/usr/lib/trino/plugin"`
* `server.log.trino.level` - string, default: `"INFO"`
* `server.config.path` - string, default: `"/etc/trino"`
* `server.config.https.enabled` - bool, default: `false`
* `server.config.https.port` - int, default: `8443`
* `server.config.https.keystore.path` - string, default: `""`
* `server.config.authenticationType` - string, default: `""`  

  Trino supports multiple [authentication types](https://trino.io/docs/current/security/authentication-types.html): PASSWORD, CERTIFICATE, OAUTH2, JWT, KERBEROS, HEADER.
* `server.config.query.maxMemory` - string, default: `"4GB"`
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
* `server.workerExtraConfig` - string, default: `""`
* `server.coordinatorExtraConfig` - string, default: `""`
* `server.autoscaling` - object, default: `{"behavior":{},"enabled":false,"maxReplicas":5,"targetCPUUtilizationPercentage":50,"targetMemoryUtilizationPercentage":80}`  

  Configure [Horizontal Pod Autoscaling](https://kubernetes.io/docs/tasks/run-application/horizontal-pod-autoscale/) for workers (`server.keda.enabled` must be `false`).
* `server.autoscaling.targetCPUUtilizationPercentage` - int, default: `50`  

  Target average CPU utilization, represented as a percentage of requested CPU. To disable scaling based on CPU, set to an empty string.
* `server.autoscaling.targetMemoryUtilizationPercentage` - int, default: `80`  

  Target average memory utilization, represented as a percentage of requested memory. To disable scaling based on memory, set to an empty string.
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
* `server.keda` - object, default: `{"advanced":{},"annotations":{},"cooldownPeriod":300,"enabled":false,"fallback":{},"initialCooldownPeriod":0,"maxReplicaCount":5,"minReplicaCount":0,"pollingInterval":30,"triggers":[]}`  

  Configure [Kubernetes Event-driven Autoscaling](https://keda.sh/) for workers (`server.autoscaling.enabled` must be `false`).
* `server.keda.cooldownPeriod` - int, default: `300`  

  Period (in seconds) to wait after the last trigger reported active before scaling the resource back to 0
* `server.keda.initialCooldownPeriod` - int, default: `0`  

  The delay (in seconds) before the `cooldownPeriod` starts after the initial creation of the `ScaledObject`.
* `server.keda.minReplicaCount` - int, default: `0`  

  Minimum number of replicas KEDA will scale the resource down to. By default, it’s scale to zero, but you can use it with some other value as well.
* `server.keda.maxReplicaCount` - int, default: `5`  

  This setting is passed to the HPA definition that KEDA will create for a given resource and holds the maximum number of replicas of the target resource.
* `server.keda.fallback` - object, default: `{}`  

  Defines a number of replicas to fall back to if a scaler is in an error state.
  Example:
  ```yaml
  fallback:             # Optional. Section to specify fallback options
    failureThreshold: 3 # Mandatory if fallback section is included
    replicas: 6         # Mandatory if fallback section is included
  ```
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
          (avg_over_time(trino_execution_name_ClusterSizeMonitor_RequiredWorkers{service={{ include "trino.fullname" . | quote }}}[5s]))
  ```
  The metric name above is the one Trino's own OpenMetrics endpoint exports,
  which `serviceMonitor` scrapes by default. The `jmx.exporter` sidecar names
  the same MBean attribute `trino_execution_ClusterSizeMonitor_RequiredWorkers`,
  without the `name_` segment.
* `server.keda.annotations` - object, default: `{}`  

  Annotations to apply to the ScaledObject CRD.
  Example:
  ```yaml
  annotations:
    autoscaling.keda.sh/paused-replicas: "0"
    autoscaling.keda.sh/paused: "true"
  ```
* `accessControl` - object, default: `{}`  

  [System access control](https://trino.io/docs/current/security/built-in-system-access-control.html) configuration.
  These settings apply to the coordinator and to the workers. Settings meant
  for one role only go in a `coordinator` or a `worker` block, where they
  override the shared ones.
  A rules document denies whatever it does not allow, and both roles serve the
  management endpoints, so a document without a `system_information` section
  denies every management read, the metrics endpoint among them, on the
  coordinator and on the workers alike. The rules are evaluated in order and
  the first one matching a user decides, so a rule that matches a user without
  granting `read` denies that user as surely as no rule at all.
  Granting a user read access to system information on workers takes nothing
  more than:
  ```yaml
   worker:
     type: configmap
     rules:
       rules.json: |-
         {
           "system_information": [
             {
               "user": "prometheus",
               "allow": ["read"]
             }
           ]
         }
  ```
  When `worker.gracefulShutdown` is enabled, the chart merges the permission to
  write system information for `worker.gracefulShutdown.user` into the worker
  rules, so the shutdown request keeps working next to the rules configured
  here. Those rules have to be of the `configmap` type, because the permission
  cannot be merged into opaque properties.
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
* `opa.enabled` - bool, default: `false`  

  Set to true to deploy an [Open Policy Agent](https://www.openpolicyagent.org/) sidecar container on the Trino coordinator pod.
  When `opa.enabled` is true and `accessControl` is left at its default
  (empty `{}`), the chart automatically wires Trino's access-control plugin
  to this sidecar using `opa.policyPath` and the optional `opa.*Path` /
  `opa.log*` / `opa.allowPermissionManagementOperations` values. To
  customize further, set `accessControl.type: properties` and provide the
  full `accessControl.properties` block; any `accessControl` value disables
  auto-wiring.
* `opa.image` - string, default: `"openpolicyagent/opa:1.16.2-static"`  

  OPA container image. The `-static` variant is recommended: it ships without a shell which keeps the attack surface small. Check for newer versions at https://hub.docker.com/r/openpolicyagent/opa/tags
* `opa.pullPolicy` - string, default: `"IfNotPresent"`
* `opa.listenAddress` - string, default: `"127.0.0.1"`  

  Address OPA binds its API to inside the coordinator pod. The default keeps it on loopback, where Trino reaches it and nothing outside the pod can: OPA's API is writable and unauthenticated, so a request that arrives there can replace the policy. The probes use `opa.diagnosticPort` rather than this address, so there is no need to widen it for them.
* `opa.port` - int, default: `8181`  

  Port OPA listens on inside the coordinator pod. The URIs Trino is given are built from it, so there is nothing else to keep in step.
* `opa.diagnosticPort` - int, default: `8282`  

  Port of OPA's read-only diagnostic listener, which serves `/health` and `/metrics` and nothing else. It binds to all addresses so the kubelet can probe it, which is why the API itself does not have to.
* `opa.policyPath` - string, default: `"/v1/data/trino/allow"`  

  Path of the document Trino asks for an authorization decision. The sidecar shares the coordinator's network, so the chart addresses it over loopback on `opa.port` and only the path is configured here.
* `opa.columnMaskingPath` - string, default: `""`  

  Path of the document for column-masking decisions. When set, the auto-wired access control adds `opa.policy.column-masking-uri`. Leave empty to omit.
* `opa.rowFiltersPath` - string, default: `""`  

  Path of the document for row-filter decisions. When set, the auto-wired access control adds `opa.policy.row-filters-uri`. Leave empty to omit.
* `opa.batchedPath` - string, default: `""`  

  Path of the document for batched authorization decisions. When set, the auto-wired access control adds `opa.policy.batched-uri`. Leave empty to omit.
* `opa.logRequests` - bool, default: `false`  

  When true, the auto-wired access-control adds `opa.log-requests=true`, logging every request Trino sends to OPA.
* `opa.logResponses` - bool, default: `false`  

  When true, the auto-wired access-control adds `opa.log-responses=true`, logging every response Trino receives from OPA.
* `opa.allowPermissionManagementOperations` - bool, default: `false`  

  When true, the auto-wired access-control adds `opa.allow-permission-management-operations=true`, allowing CREATE/DROP ROLE, GRANT, REVOKE, and similar statements without OPA evaluation.
* `opa.policy` - object, default: `{}`  

  Rego policy files to render into a ConfigMap and mount into the OPA container at `opa.policyMountPath`. Provide one or more entries, each keyed by file name (e.g. `policy.rego`, `data.json`). Mutually exclusive with `opa.policyConfigMap`. Exactly one of the two must be set when `opa.enabled` is true.
  Example:
  ```yaml
  policy:
    policy.rego: |
      package trino
      import rego.v1
      default allow := false
      allow if {
        input.context.identity.user == "alice"
      }
  ```
* `opa.policyConfigMap` - string, default: `""`  

  Name of an existing ConfigMap holding the OPA policy files. Mutually exclusive with `opa.policy`.
* `opa.policyMountPath` - string, default: `"/policies"`  

  Directory inside the OPA container where the policy files are mounted.
* `opa.extraArgs` - list, default: `[]`  

  Additional flags appended to the `opa run` command, before the policy directory positional argument.
  Example:
  ```yaml
  extraArgs:
    - --log-level=debug
  ```
* `opa.securityContext` - object, default: `{"allowPrivilegeEscalation":false,"capabilities":{"drop":["ALL"]},"readOnlyRootFilesystem":true,"runAsGroup":65532,"runAsNonRoot":true,"runAsUser":65532,"seccompProfile":{"type":"RuntimeDefault"}}`  

  [Security context](https://kubernetes.io/docs/tasks/configure-pod-container/security-context/#set-the-security-context-for-a-container) for the OPA container. Defaults to a hardened, non-root, read-only-root configuration. Override fields explicitly if your environment requires it.
* `opa.resources` - object, default: `{"limits":{"memory":"512Mi"},"requests":{"cpu":"250m","memory":"256Mi"}}`  

  Resource requests and limits for the OPA container.
  Set to `{}` to opt out of any resource defaults.
* `opa.livenessProbe.initialDelaySeconds` - int, default: `5`
* `opa.livenessProbe.periodSeconds` - int, default: `10`
* `opa.livenessProbe.timeoutSeconds` - int, default: `5`
* `opa.livenessProbe.failureThreshold` - int, default: `3`
* `opa.livenessProbe.successThreshold` - int, default: `1`
* `opa.readinessProbe.initialDelaySeconds` - int, default: `5`
* `opa.readinessProbe.periodSeconds` - int, default: `10`
* `opa.readinessProbe.timeoutSeconds` - int, default: `5`
* `opa.readinessProbe.failureThreshold` - int, default: `3`
* `opa.readinessProbe.successThreshold` - int, default: `1`
* `headerAuthenticator` - object, default: `{}`  

  [Header authenticator](https://trino.io/docs/current/develop/header-authenticator.html) configuration. Required when `server.config.authenticationType` contains `HEADER`.
  Provide the plugin configuration properties. The `header-authenticator.name` value must
  match the name of the installed authenticator plugin.
  ```yaml
  headerAuthenticator:
    properties: |
      header-authenticator.name=my-header-authenticator
      header-authenticator.username-header=X-Authenticated-User
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
* `additionalNodeProperties` - list, default: `[]`  

  [Additional node properties](https://trino.io/docs/current/installation/deployment.html#log-levels). Supports templating the entries with `tpl`; an entry that renders empty is omitted.
  Example, assuming the NODE_ID environment variable has been set:
  ```yaml
   - node.id=${NODE_ID}
   - 'node.pool={{ .Values.global.nodePoolId }}'
  ```
* `additionalConfigProperties` - list, default: `[]`  

  [Additional config properties](https://trino.io/docs/current/admin/properties.html). Supports templating the entries with `tpl`; an entry that renders empty is omitted.
  Example:
  ```yaml
   - internal-communication.shared-secret=random-value-999
   - http-server.process-forwarded=true
   - '{{ if .Values.global.monitoring.enabled }}tracing.enabled=true{{ end }}'
  ```
* `additionalLogProperties` - list, default: `[]`  

  [Additional log properties](https://trino.io/docs/current/installation/deployment.html#log-levels). Supports templating the entries with `tpl`; an entry that renders empty is omitted.
  Example:
  ```yaml
   - io.airlift=DEBUG
   - 'io.trino.plugin.hive={{ .Values.global.hiveLogLevel }}'
  ```
* `additionalExchangeManagerProperties` - list, default: `[]`  

  [Exchange manager properties](https://trino.io/docs/current/admin/fault-tolerant-execution.html#exchange-manager). Supports templating the entries with `tpl`; an entry that renders empty is omitted.
  Example:
  ```yaml
   - exchange.s3.region=object-store-region
   - exchange.s3.endpoint=your-object-store-endpoint
   - exchange.s3.aws-access-key=your-access-key
   - exchange.s3.aws-secret-key=your-secret-key
   - 'exchange.s3.region={{ .Values.global.objectStoreRegion }}'
  ```
* `sessionProperties` - object, default: `{}`  

  [Session properties manager config file](https://trino.io/docs/current/admin/session-property-managers.html) is mounted to {{ .Values.server.config.path }}/session-property-config.json
  Set the type property to either:
  * `configmap`, and provide the session properties manager file contents in `sessionPropertiesConfig`,
  * `properties`, and provide configuration properties in `properties`.
* `eventListenerProperties` - list, default: `[]`  

  [Event listener](https://trino.io/docs/current/develop/event-listener.html#event-listener) properties. To configure multiple event listeners, add them in `coordinator.additionalConfigFiles` and `worker.additionalConfigFiles`, and set the `event-listener.config-files` property in `additionalConfigProperties` to their locations. Supports templating the entries with `tpl`; an entry that renders empty is omitted, and no event listener file is written when every entry does.
  Example:
  ```yaml
   - event-listener.name=custom-event-listener
   - custom-property1=custom-value1
   - custom-property2=custom-value2
   - 'custom-property3={{ .Values.global.customValue }}'
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
  Supports templating with `tpl`.
* `additionalCatalogs` - object, default: `{}`  

  Deprecated, use `catalogs` instead. Configure additional [catalogs](https://trino.io/docs/current/installation/deployment.html#catalog-properties).
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
* `securityContext` - object, default: `{"runAsGroup":1000,"runAsUser":1000}`  

  [Pod security context](https://kubernetes.io/docs/tasks/configure-pod-container/security-context/#set-the-security-context-for-a-pod) configuration. To remove the default, set it to null (or `~`).
* `containerSecurityContext` - object, default: `{"allowPrivilegeEscalation":false,"capabilities":{"drop":["ALL"]}}`  

  [Container security context](https://kubernetes.io/docs/tasks/configure-pod-container/security-context/#set-the-security-context-for-a-container) configuration.
* `containerSecurityContext.allowPrivilegeEscalation` - bool, default: `false`  

  Control whether a process can gain more privileges than its parent process.
* `containerSecurityContext.capabilities.drop` - list, default: `["ALL"]`  

  A list of the Linux kernel capabilities that are dropped from every container. Valid values are listed in [the capabilities manual page](https://man7.org/linux/man-pages/man7/capabilities.7.html). Ensure # to remove the "CAP_" prefix which the kernel attaches to the names of permissions.
* `shareProcessNamespace.coordinator` - bool, default: `false`
* `shareProcessNamespace.worker` - bool, default: `false`
* `service.annotations` - object, default: `{}`
* `service.type` - string, default: `"ClusterIP"`
* `service.port` - int, default: `8080`
* `service.nodePort` - string, default: `""`  

  The port the service listens on the host, for the `NodePort` type. If not set, Kubernetes will [allocate a port automatically](https://kubernetes.io/docs/concepts/services-networking/service/#nodeport-custom-port).
* `service.appProtocols` - object, default: `{}`  

  The [application protocol](https://kubernetes.io/docs/concepts/services-networking/service/#application-protocol) of a service port, keyed by the name of the port. A service mesh reads it to choose the protocol it speaks to the pods, which is what keeps an HTTP/2 client from being downgraded to HTTP/1.1. The names of the ports are `http`, `https`, `jmx-exporter`, and the `name` of every entry in `additionalExposedPorts`. There is no default, because the right value differs per port: `kubernetes.io/h2c` means cleartext HTTP/2, so it is wrong for a TLS port and for a port that does not speak HTTP at all.
  Example
  ```yaml
  appProtocols:
    http: kubernetes.io/h2c
    https: https
  ```
* `service.loadBalancerSourceRanges` - list, default: `[]`  

  The client address ranges allowed to reach the service, for the `LoadBalancer` type. The cloud provider turns them into the load balancer's own access rules, such as the security group of an AWS NLB. If empty or not set, the load balancer accepts traffic from anywhere.
  Example
  ```yaml
  loadBalancerSourceRanges:
    - 1.2.3.4/32
    - 10.0.0.0/8
  ```
* `service.coordinator` - object, default: `{}`  

  Override service configurations for the coordinator service.
  Example
  ```yaml
  coordinator:
    type: LoadBalancer
    annotations:
      external-dns.alpha.kubernetes.io/hostname: trino.example.com
  ```
* `service.worker` - object, default: `{}`  

  Override service configurations for the worker service. The worker service is headless, so only the settings that apply to a headless service can be overridden. Setting any other one fails the rendering instead of being silently ignored.
  Example
  ```yaml
  worker:
    annotations:
      consul.hashicorp.com/service-sync: "false"
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
   groupsAuthSecret: "trino-groups-authentication"
  ```
* `serviceAccount.create` - bool, default: `false`  

  Specifies whether a service account should be created
* `serviceAccount.name` - string, default: `""`  

  The name of the service account to use. If not set and create is true, a name is generated using the fullname template
* `serviceAccount.annotations` - object, default: `{}`  

  Annotations to add to the service account
* `configMounts` - list, default: `[]`  

  Allows mounting additional Trino configuration files from Kubernetes config maps on all nodes.
  Example:
  ```yaml
   - name: sample-config-mount
     configMap: sample-config-map
     path: /config-map/sample.json
     subPath: sample.json
  ```
* `secretMounts` - list, default: `[]`  

  Allows mounting additional Trino configuration files from Kubernetes secrets on all nodes.
  Example:
  ```yaml
   - name: sample-secret
     secretName: sample-secret
     path: /secrets/sample.json
     subPath: sample.json
  ```
* `csiSecretMounts` - list, default: `[]`  

  Allows mounting secrets on all nodes using the [Secrets Store CSI driver](https://secrets-store-csi-driver.sigs.k8s.io/). Each entry creates a volume of type `secrets-store.csi.k8s.io` referencing a `SecretProviderClass` and a matching volume mount on the Trino container. This enables consuming secrets from external stores (AWS Secrets Manager, HashiCorp Vault, Azure Key Vault, etc.) without first materializing a Kubernetes `Secret`. Requires the driver and its provider to be installed in the cluster, and the `SecretProviderClass` to exist in the release namespace.
  Example:
  ```yaml
   - name: sample-csi-secret
     secretProviderClass: sample-secret-provider-class
     path: /secrets/sample.json
     subPath: sample.json
  ```
* `coordinator.deployment.annotations` - object, default: `{}`
* `coordinator.deployment.progressDeadlineSeconds` - int, default: `600`  

  The maximum time in seconds for a deployment to make progress before it is considered failed. The deployment controller continues to process failed deployments and a condition with a ProgressDeadlineExceeded reason is surfaced in the deployment status.
* `coordinator.deployment.revisionHistoryLimit` - int, default: `10`  

  The number of old ReplicaSets to retain to allow rollback.
* `coordinator.deployment.strategy` - object, default: `{}`  

  The deployment strategy to use to replace existing pods with new ones.
* `coordinator.jvm.maxHeapSize` - string, default: `"8G"`
* `coordinator.jvm.minHeapSize` - string, default: `nil`
* `coordinator.jvm.maxHeapPercent` - string, default: `nil`  

  Alternative method of setting heap size as a percentage of container memory limits, which is recommended for better JVM ergonomics. `maxHeapSize` must be unset for this to work.
* `coordinator.jvm.initialHeapPercent` - string, default: `nil`  

  sets the starting heap size as a percentage of container memory limits.  NOTE: to disable dynamic heap resizing when setting the size as a percent, add `-XX:MaxHeapFreeRatio=100` or `-XX:-UseAdaptiveSizePolicy` to `additionalJVMConfig`.
* `coordinator.jvm.gcMethod.type` - string, default: `"UseG1GC"`
* `coordinator.jvm.gcMethod.g1.heapRegionSize` - string, default: `"32M"`
* `coordinator.config.memory.heapHeadroomPerNode` - string, default: `""`
* `coordinator.config.nodeScheduler.includeCoordinator` - bool, default: `false`  

  Allows scheduling work on the coordinator so that a single machine can function as both coordinator and worker. For large clusters, processing work on the coordinator can negatively impact query performance because the machine's resources are not available for the critical coordinator tasks of scheduling, managing, and monitoring query execution.
* `coordinator.config.query.maxMemoryPerNode` - string, default: `"1GB"`
* `coordinator.additionalJVMConfig` - list, default: `[]`
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
* `coordinator.startupProbe` - object, default: `{}`  

  [Startup probe](https://kubernetes.io/docs/tasks/configure-pod-container/configure-liveness-readiness-startup-probes/#configure-probes)
  Example:
  ```yaml
   initialDelaySeconds: 10
   periodSeconds: 2
   timeoutSeconds: 2
   failureThreshold: 60
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
* `coordinator.hostAliases` - list, default: `[]`  

  [Adding entries to Pod /etc/hosts with HostAliases] (https://kubernetes.io/docs/tasks/network/customize-hosts-file-for-pods/).
  Example:
  ```yaml
   - hostnames:
     - name-1
     - name-2
     - name-3
     ip: 1.1.1.1
  ```
* `coordinator.additionalConfigFiles` - object, default: `{}`  

  Additional config files placed in the default configuration directory. Supports templating the files' contents with `tpl`.
  Example:
  ```yaml
  secret.txt: |
    secret-value={{- .Values.someValue }}
  ```
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
* `coordinator.priorityClassName` - string, default: `nil`
* `coordinator.annotations` - object, default: `{}`  

  Annotations to add to the coordinator pod.
  By default, the following annotations are added to the coordinator pod:
  - `checksum/access-control-config` - checksum of the coordinator access control config file;
  - `checksum/catalog-config` - checksum of the catalog config file;
  - `checksum/coordinator-config` - checksum of the coordinator config file.
  This allows for automatic rolling updates on configuration changes. This behaviour can be disabled by manually
  setting these annotations to fixed constants in the `coordinator.annotations` section.
  Example:
  ```yaml
   annotations:
     checksum/access-control-config: ""
     checksum/catalog-config: ""
     checksum/coordinator-config: ""
  ```
* `coordinator.labels` - object, default: `{}`
* `coordinator.configMounts` - list, default: `[]`  

  Allows mounting additional Trino configuration files from Kubernetes config maps on the coordinator node.
  Example:
  ```yaml
   - name: sample-config-mount
     configMap: sample-config-mount
     path: /config-mount/sample.json
     subPath: sample.json
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
* `coordinator.csiSecretMounts` - list, default: `[]`  

  Allows mounting secrets on the coordinator node using the [Secrets Store CSI driver](https://secrets-store-csi-driver.sigs.k8s.io/). Each entry creates a volume of type `secrets-store.csi.k8s.io` referencing a `SecretProviderClass` and a matching volume mount on the Trino container. This enables consuming secrets from external stores (AWS Secrets Manager, HashiCorp Vault, Azure Key Vault, etc.) without first materializing a Kubernetes `Secret`. Requires the driver and its provider to be installed in the cluster, and the `SecretProviderClass` to exist in the release namespace.
  Example:
  ```yaml
   - name: sample-csi-secret
     secretProviderClass: sample-secret-provider-class
     path: /secrets/sample.json
     subPath: sample.json
  ```
* `worker.deployment.annotations` - object, default: `{}`
* `worker.deployment.progressDeadlineSeconds` - int, default: `600`  

  The maximum time in seconds for a deployment to make progress before it is considered failed. The deployment controller continues to process failed deployments and a condition with a ProgressDeadlineExceeded reason is surfaced in the deployment status.
* `worker.deployment.revisionHistoryLimit` - int, default: `10`  

  The number of old ReplicaSets to retain to allow rollback.
* `worker.deployment.strategy` - object, default: `{}`  

  The deployment strategy to use to replace existing pods with new ones.
* `worker.podDisruptionBudget` - object, default: `{}`  

  Worker [Pod Disruption Budget](https://kubernetes.io/docs/concepts/workloads/pods/disruptions/#pod-disruption-budgets) configuration. The contents are rendered into the budget's `spec`, so any field the API supports can be set here. Nothing is created while this is empty.
  ```yaml
  podDisruptionBudget:
    # minAvailable and maxUnavailable are mutually exclusive
    minAvailable: 1
  ```
* `worker.jvm.maxHeapSize` - string, default: `"8G"`
* `worker.jvm.minHeapSize` - string, default: `nil`
* `worker.jvm.maxHeapPercent` - string, default: `nil`
* `worker.jvm.initialHeapPercent` - string, default: `nil`
* `worker.jvm.gcMethod.type` - string, default: `"UseG1GC"`
* `worker.jvm.gcMethod.g1.heapRegionSize` - string, default: `"32M"`
* `worker.config.memory.heapHeadroomPerNode` - string, default: `""`
* `worker.config.query.maxMemoryPerNode` - string, default: `"1GB"`
* `worker.additionalJVMConfig` - list, default: `[]`
* `worker.additionalExposedPorts` - object, default: `{}`  

  Additional container ports configured in all worker pods and the worker service.
  Example:
  ```yaml
   https:
     servicePort: 8443
     name: https
     port: 8443
     protocol: TCP
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
* `worker.startupProbe` - object, default: `{}`  

  [Startup probe](https://kubernetes.io/docs/tasks/configure-pod-container/configure-liveness-readiness-startup-probes/#configure-probes)
  Example:
  ```yaml
   initialDelaySeconds: 10
   periodSeconds: 2
   timeoutSeconds: 2
   failureThreshold: 60
   successThreshold: 1
  ```
* `worker.lifecycle` - object, default: `{}`  

  Worker container [lifecycle events](https://kubernetes.io/docs/tasks/configure-pod-container/attach-handler-lifecycle-event/)  Setting `worker.lifecycle` conflicts with `worker.gracefulShutdown`.
  Example:
  ```yaml
   preStop:
     exec:
       command: ["/bin/sh", "-c", "sleep 120"]
  ```
* `worker.gracefulShutdown` - object, default: `{"enabled":false,"gracePeriodSeconds":120,"user":"admin"}`  

  Configure [graceful shutdown](https://trino.io/docs/current/admin/graceful-shutdown.html) in order to ensure that workers terminate without affecting running queries, given a sufficient grace period. When enabled, the value of `worker.terminationGracePeriodSeconds` must be at least two times greater than the configured `gracePeriodSeconds`. Enabling `worker.gracefulShutdown` conflicts with `worker.lifecycle`. When a custom `worker.lifecycle` configuration needs to be used, graceful shutdown must be configured manually.
  The shutdown request is sent as `user`, and the chart permits that user to read and write system information in
  the worker access control rules, merging the permissions into the rules set in `accessControl`. Read access is
  granted as well because the first rule matching a user decides, so a rule granting only write would deny that
  user every management read.
  Example:
  ```yaml
   gracefulShutdown:
     enabled: true
     gracePeriodSeconds: 120
     user: admin
  ```
* `worker.terminationGracePeriodSeconds` - int, default: `30`
* `worker.nodeSelector` - object, default: `{}`
* `worker.tolerations` - list, default: `[]`
* `worker.affinity` - object, default: `{}`
* `worker.hostAliases` - list, default: `[]`  

  [Adding entries to Pod /etc/hosts with HostAliases] (https://kubernetes.io/docs/tasks/network/customize-hosts-file-for-pods/).
  Example:
  ```yaml
   - hostnames:
     - name-1
     - name-2
     - name-3
     ip: 1.1.1.1
  ```
* `worker.topologySpreadConstraints` - list, default: `[]`  

  Configure [topology spread constraints](https://kubernetes.io/docs/concepts/scheduling-eviction/topology-spread-constraints/) to control how worker pods are spread across your cluster among failure-domains such as nodes, zones, and regions. This is a best practice for achieving high availability and preventing resource hotspots.
  Example of spreading workers across hostnames and zones:
  ```yaml
  topologySpreadConstraints:
    - maxSkew: 1
      topologyKey: "kubernetes.io/hostname"
      whenUnsatisfiable: "ScheduleAnyway"
      labelSelector:
        matchLabels:
          app.kubernetes.io/name: trino
          app.kubernetes.io/component: worker
    - maxSkew: 1
      topologyKey: "topology.kubernetes.io/zone"
      whenUnsatisfiable: "DoNotSchedule"
      labelSelector:
        matchLabels:
          app.kubernetes.io/name: trino
          app.kubernetes.io/component: worker
  ```
* `worker.additionalConfigFiles` - object, default: `{}`  

  Additional config files placed in the default configuration directory. Supports templating the files' contents with `tpl`.
  Example:
  ```yaml
  secret.txt: |
    secret-value={{- .Values.someValue }}
  ```
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
* `worker.priorityClassName` - string, default: `nil`
* `worker.annotations` - object, default: `{}`  

  Annotations to add to the worker pods.
  By default, the following annotations are added to the worker pods:
  - `checksum/access-control-config` - checksum of the worker access control config file;
  - `checksum/catalog-config` - checksum of the catalog config file;
  - `checksum/worker-config` - checksum of the worker config file.
  This allows for automatic rolling updates on configuration changes. This behaviour can be disabled by manually
  setting these annotations to fixed constants in the `worker.annotations` section.
  Example:
  ```yaml
   annotations:
     checksum/access-control-config: ""
     checksum/catalog-config: ""
     checksum/worker-config: ""
  ```
* `worker.labels` - object, default: `{}`
* `worker.configMounts` - list, default: `[]`  

  Allows mounting additional Trino configuration files from Kubernetes config maps on all worker nodes.
  Example:
  ```yaml
  - name: sample-config-mount
    configMap: sample-config-mount
    path: /config-mount/sample.json
    subPath: sample.json
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
* `worker.csiSecretMounts` - list, default: `[]`  

  Allows mounting secrets on all worker nodes using the [Secrets Store CSI driver](https://secrets-store-csi-driver.sigs.k8s.io/). Each entry creates a volume of type `secrets-store.csi.k8s.io` referencing a `SecretProviderClass` and a matching volume mount on the Trino container. This enables consuming secrets from external stores (AWS Secrets Manager, HashiCorp Vault, Azure Key Vault, etc.) without first materializing a Kubernetes `Secret`. Requires the driver and its provider to be installed in the cluster, and the `SecretProviderClass` to exist in the release namespace.
  Example:
  ```yaml
   - name: sample-csi-secret
     secretProviderClass: sample-secret-provider-class
     path: /secrets/sample.json
     subPath: sample.json
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
* `jmx.enabled` - bool, default: `false`  

  Set to true to enable the RMI server to expose Trino's [JMX metrics](https://trino.io/docs/current/admin/jmx.html).
* `jmx.registryPort` - int, default: `9080`
* `jmx.serverPort` - int, default: `9081`
* `jmx.exporter.enabled` - bool, default: `false`  

  Set to true to run the [JMX exporter](https://github.com/prometheus/jmx_exporter) as a sidecar and export JMX metrics over its own HTTP port. Every Trino node already serves its metrics itself, see `serviceMonitor.openMetrics`, so this is only needed to keep the exporter's metric names or to reach MBeans the OpenMetrics endpoint does not expose.
* `jmx.exporter.image` - string, default: `"bitnamilegacy/jmx-exporter:1.4.0"`  

  The upstream project publishes no runnable image, and `bitnamilegacy` is Bitnami's archived namespace, so this tag receives no further updates or CVE patches. It stays the default only because a default has to pull without credentials.
  Prefer `serviceMonitor.openMetrics`, which needs no sidecar at all. If you
  do need the sidecar, Docker Hardened Images publishes a maintained
  `jmx-exporter` under Apache-2.0 at no cost, and pulling it needs a Docker
  account, so it takes an `imagePullSecrets` entry:
  ```yaml
  imagePullSecrets:
    - name: dhi-credentials
  jmx:
    exporter:
      image: dhi.io/jmx-exporter:TAG
  ```
  Pick a tag from the [catalog
  entry](https://hub.docker.com/hardened-images/catalog/dhi/jmx-exporter),
  and see [the Docker
  documentation](https://docs.docker.com/dhi/how-to/use/) for the
  credentials `dhi.io` expects.
* `jmx.exporter.pullPolicy` - string, default: `"IfNotPresent"`  

  The default tag is pinned to an immutable image in an archived namespace, so pulling it again on every start would only make that registry a startup dependency.
* `jmx.exporter.port` - int, default: `5556`
* `jmx.exporter.env` - list, default: `[]`  

  environment variables specifically for the JMX exporter container, specified as a list with explicit values
* `jmx.exporter.envFrom` - list, default: `[]`  

  environment variables specifically for the JMX exporter container, specified as a list of either `ConfigMap` or `Secret` references
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
* `jmx.exporter.securityContext` - object, default: `{}`
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
* `jmx.worker` - object, default: `{}`  

  Override JMX configurations for the Trino workers.
  Example
  ```yaml
  worker:
    enabled: true
    exporter:
      enabled: true
  ```
* `serviceMonitor.enabled` - bool, default: `false`  

  Set to true to create resources for the [prometheus-operator](https://github.com/prometheus-operator/prometheus-operator).
* `serviceMonitor.apiVersion` - string, default: `"monitoring.coreos.com/v1"`
* `serviceMonitor.labels` - object, default: `{"prometheus":"kube-prometheus"}`  

  Labels for serviceMonitor, so that Prometheus can select it
* `serviceMonitor.interval` - string, default: `"30s"`  

  The serviceMonitor web endpoint interval
* `serviceMonitor.scrapeTimeout` - string, default: `""`  

  Maximum time to wait for a response. If empty or not set, uses the Prometheus global default.
* `serviceMonitor.openMetrics.enabled` - bool, default: `true`  

  Scrape the [OpenMetrics](https://trino.io/docs/current/admin/openmetrics.html) endpoint every Trino node serves on its own HTTP port. This needs no sidecar, and it is the recommended metrics source. The `jmx.exporter` sidecar is scraped as well whenever a role runs one, so both metric sets can be collected side by side.
  Trino exports every MBean it registers itself. Add JVM level beans, which
  it does not register, with the `openmetrics.jmx-object-names` property in
  `additionalConfigProperties`:
  ```yaml
  additionalConfigProperties:
    - openmetrics.jmx-object-names=java.lang:*
  ```
* `serviceMonitor.openMetrics.path` - string, default: `"/metrics"`
* `serviceMonitor.openMetrics.username` - string, default: `"admin"`  

  The Trino user the scrape authenticates as. Reading `/metrics` is a management read, so a file-based `accessControl` rule set has to allow this user `read` on `system_information` or the scrape gets a 403.
  ```yaml
  accessControl:
    type: configmap
    rules:
      rules.json: |-
        {"system_information": [{"user": "admin", "allow": ["read"]}]}
  ```
  `serviceMonitor.worker.enabled` set to `false` stops scraping the workers
  if you would rather not grant it there.
* `serviceMonitor.openMetrics.password` - string, default: `""`  

  The password sent with the username, on the coordinator alone: only it is given an authentication type, so a worker rejects a password and rendering fails rather than leaving you a scrape that cannot authenticate. An empty value sends no password, which is what an unsecured cluster wants.
  An authentication type Prometheus cannot speak, such as `OAUTH2`, has one
  more way out: `management.user` lets management endpoints through without
  credentials. It applies to every management endpoint, not just
  `/metrics`.
  ```yaml
  additionalConfigProperties:
    - management.user=prometheus
    - management.user.https-enabled=true
  ```
* `serviceMonitor.openMetrics.authSecret` - string, default: `""`  

  Name of an existing Secret in the release namespace holding `username` and `password` keys. The chart creates that Secret from the two values above when this is empty.
* `serviceMonitor.tlsConfig` - object, default: `{}`  

  TLS settings for the scrape, needed when `server.config.https.enabled` is set and Prometheus cannot verify the coordinator's certificate. Only the coordinator serves https, so this reaches its endpoint alone.
* `serviceMonitor.endpoints` - list, default: `[]`  

  Describe the scrape yourself instead of letting the chart derive it. This replaces the generated endpoints entirely, so nothing else in this block applies to a role that sets it.
  Example:
  ```yaml
  endpoints:
    - port: http
      path: /metrics
      interval: 30s
      relabelings:
        - action: replace
          replacement: trino-coordinator
          targetLabel: job
  ```
* `serviceMonitor.coordinator` - object, default: `{}`  

  Override ServiceMonitor configurations for the Trino coordinator.
  Example
  ```yaml
  coordinator:
    enabled: true
    labels:
      prometheus: my-prometheus
    openMetrics:
      username: prometheus
  ```
* `serviceMonitor.worker` - object, default: `{}`  

  Override ServiceMonitor configurations for the Trino workers.
  Example
  ```yaml
  worker:
    enabled: true
    labels:
      prometheus: my-prometheus
    openMetrics:
      enabled: false
  ```
* `commonLabels` - object, default: `{}`  

  Labels that get applied to every resource's metadata
* `ingress.enabled` - bool, default: `false`
* `ingress.className` - string, default: `""`
* `ingress.annotations` - object, default: `{}`
* `ingress.hosts` - list, default: `[]`  

  [Ingress rules](https://kubernetes.io/docs/concepts/services-networking/ingress/#ingress-rules). Supports templating the `host` values with `tpl`.
  Example:
  ```yaml
   - host: trino.example.com
     paths:
       - path: /
         pathType: ImplementationSpecific
  ```
* `ingress.tls` - list, default: `[]`  

  Ingress [TLS](https://kubernetes.io/docs/concepts/services-networking/ingress/#tls) configuration. Supports templating the `hosts` and `secretName` values with `tpl`.
  Example:
  ```yaml
   - secretName: chart-example-tls
     hosts:
       - chart-example.local
  ```
* `gateway.enabled` - bool, default: `false`  

  Set to true to create HTTPRoute resources for [Kubernetes Gateway API](https://gateway-api.sigs.k8s.io/). The Gateway API is the successor to the Ingress API and provides more advanced routing capabilities.
  > [!NOTE]
  > - Requires Gateway API CRDs to be installed in the cluster
  > - Not recommended to use together with `ingress.enabled` (choose one or the other)
  > - Requires a Gateway resource to be configured separately
* `gateway.annotations` - object, default: `{}`  

  Annotations to add to the HTTPRoute resource.
  Example:
  ```yaml
   gateway.networking.k8s.io/example: "value"
  ```
* `gateway.parentRefs` - list, default: `[]`  

  References to the Gateway resources that this HTTPRoute should attach to.
  Example:
  ```yaml
   - name: trino-gateway
     namespace: gateway-system
     sectionName: https
  ```
* `gateway.hostnames` - list, default: `[]`  

  Hostnames to match for routing traffic.
  Example:
  ```yaml
   - trino.example.com
   - trino-prod.example.com
  ```
* `gateway.rules` - list, default: `[]`  

  HTTPRoute rules for routing traffic to Trino. Each rule can use either the simplified `path` format for basic routing, or the full `matches` format for advanced use cases.
  Simple path-based routing example:
  ```yaml
   - path:
       type: PathPrefix
       value: /
     filters:
       - type: RequestHeaderModifier
         requestHeaderModifier:
           set:
             - name: X-Forwarded-Proto
               value: https
  ```
  Advanced matching example with headers:
  ```yaml
   - matches:
       - path:
           type: PathPrefix
           value: /ui
         headers:
           - name: X-Custom-Header
             value: custom-value
     filters:
       - type: RequestHeaderModifier
         requestHeaderModifier:
           set:
             - name: X-Forwarded-Proto
               value: https
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
* `extraManifests` - list, default: `[]`  

  Array of extra kubernetes manifests to deploy with the release. Strings are evaluated as a template and can use template expansions and functions. All other objects are used as yaml.

----------------------------------------------
Autogenerated from chart metadata using [helm-docs v1.14.2](https://github.com/norwoodj/helm-docs/releases/v1.14.2)
