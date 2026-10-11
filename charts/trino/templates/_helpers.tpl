{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{- define "trino.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "trino.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- if eq .Release.Name $name }}
{{- $name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "trino.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{- define "trino.coordinator" -}}
{{- if .Values.coordinatorNameOverride }}
{{- .Values.coordinatorNameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" (include "trino.fullname" .) "coordinator" | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}

{{- define "trino.worker" -}}
{{- if .Values.workerNameOverride }}
{{- .Values.workerNameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" (include "trino.fullname" .) "worker" | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}


{{- define "trino.catalog" -}}
{{ template "trino.fullname" . }}-catalog
{{- end -}}

{{/*
Common labels, with commonLabels set over them so it can override any of them.
Returns YAML, so call it through fromYaml to add more labels to it.
*/}}
{{- define "trino.labels" -}}
{{- $labels := include "trino.selectorLabels" . | fromYaml }}
{{- $_ := set $labels "helm.sh/chart" (include "trino.chart" .) }}
{{- $_ := set $labels "app.kubernetes.io/managed-by" .Release.Service }}
{{- if .Chart.AppVersion }}
{{- $_ := set $labels "app.kubernetes.io/version" .Chart.AppVersion }}
{{- end }}
{{- range $key, $value := .Values.commonLabels }}
{{- $_ := set $labels $key $value }}
{{- end }}
{{- tpl (toYaml $labels) . }}
{{- end }}

{{/*
The labels of a role's deployment and its pods: the common labels, the role and
network policy labels, and the user supplied labels set over them. Takes
`context`, `role` and `labels`.
*/}}
{{- define "trino.roleLabels" -}}
{{- $labels := include "trino.labels" .context | fromYaml }}
{{- $_ := set $labels "app.kubernetes.io/component" .role }}
{{- $_ := set $labels "trino.io/network-policy-protection" (ternary "enabled" "disabled" .context.Values.networkPolicy.enabled) }}
{{- range $key, $value := .labels }}
{{- $_ := set $labels $key $value }}
{{- end }}
{{- tpl (toYaml $labels) .context }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "trino.selectorLabels" -}}
app.kubernetes.io/name: {{ include "trino.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "trino.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "trino.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Return the proper image name
{{ include "trino.image" . }}

Code is inspired from bitnami/common

*/}}
{{- define "trino.image" -}}
{{- $repositoryName := .Values.image.repository -}}
{{- if .Values.image.useRepositoryAsSoleImageReference -}}
  {{- printf "%s" $repositoryName -}}
{{- else -}}
  {{- $repositoryName := .Values.image.repository -}}
  {{- $registryName := .Values.image.registry -}}
  {{- $separator := ":" -}}
  {{- $termination := (default .Chart.AppVersion .Values.image.tag) | toString -}}
  {{- if .Values.image.digest }}
    {{- $separator = "@" -}}
    {{- $termination = .Values.image.digest | toString -}}
  {{- end -}}
  {{- if $registryName }}
    {{- printf "%s/%s%s%s" $registryName $repositoryName $separator $termination -}}
  {{- else -}}
    {{- printf "%s%s%s"  $repositoryName $separator $termination -}}
  {{- end -}}
{{- end -}}
{{- end -}}

{{/*
Fail on a scrape password the workers cannot use. Only the coordinator is given
an authentication type, so a worker answers /metrics through Trino's insecure
authenticator, and that one rejects a password rather than ignoring it. A
password set for both roles is therefore wrong for one of them. Takes the root
context.
*/}}
{{- define "trino.checkWorkerScrapePassword" -}}
{{- $shared := (.Values.serviceMonitor.openMetrics | default dict).password -}}
{{- $worker := ((.Values.serviceMonitor.worker | default dict).openMetrics | default dict) -}}
{{- if and $shared (not (hasKey $worker "password")) -}}
{{- fail "serviceMonitor.openMetrics.password also reaches the workers, which reject a password. Set serviceMonitor.coordinator.openMetrics.password instead, or serviceMonitor.worker.openMetrics.password as well if you gave the workers an authenticator of your own." -}}
{{- end -}}
{{- end }}

{{/*
The image reference of one of the containers the chart's Helm tests run. Takes
`context` and `image`, a block of `testImages`. The registry comes from
`image.registry`, so a mirror set up for the Trino image serves these too.
*/}}
{{- define "trino.testImage" -}}
{{- $reference := printf "%s:%s" .image.repository (.image.tag | toString) -}}
{{- with .context.Values.image.registry -}}
{{- printf "%s/%s" . $reference -}}
{{- else -}}
{{- $reference -}}
{{- end -}}
{{- end -}}

{{/*
Create the secret name for the file-based authentication's password file
*/}}
{{- define "trino.passwordSecretName" -}}
{{- if and .Values.auth .Values.auth.passwordAuthSecret }}
{{- .Values.auth.passwordAuthSecret | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" (include "trino.fullname" .) "password-file" | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}

{{/*
Create the secret name for the group-provider file
*/}}
{{- define "trino.groupsSecretName" -}}
{{- if and .Values.auth .Values.auth.groupsAuthSecret }}
{{- .Values.auth.groupsAuthSecret }}
{{- else }}
{{- printf "%s-%s" (include "trino.fullname" .) "groups-file" | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}

{{/*
The name of the Secret holding the credentials the ServiceMonitor authenticates
its scrape with: the one the user named, or the one the chart creates for the
role. Takes `context`, `role` and `serviceMonitor`, the role's settings.
*/}}
{{- define "trino.serviceMonitorAuthSecretName" -}}
{{- with .serviceMonitor.openMetrics.authSecret -}}
{{- . -}}
{{- else -}}
{{- printf "%s-metrics-auth-%s" (include "trino.fullname" .context) .role | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}

{{/*
The endpoints of a role's ServiceMonitor: Trino's own OpenMetrics endpoint, and
the JMX exporter sidecar's when that role runs one. Takes `context`, `role`,
`serviceMonitor` and `jmx`, the role's settings. Returns YAML, so call it
through nindent.
*/}}
{{- define "trino.serviceMonitorEndpoints" -}}
{{- $serviceMonitor := .serviceMonitor -}}
{{- with $serviceMonitor.endpoints -}}
{{- toYaml . -}}
{{- else -}}
{{- $endpoints := list -}}
{{- if $serviceMonitor.openMetrics.enabled -}}
{{/* only the coordinator gets http-server.https.enabled, so a worker serves
     /metrics over plain http however server.config.https is set */}}
{{- $https := and .context.Values.server.config.https.enabled (eq .role "coordinator") -}}
{{- $secret := include "trino.serviceMonitorAuthSecretName" . -}}
{{- $endpoint := dict
      "port" (ternary "https" "http" $https)
      "scheme" (ternary "https" "http" $https)
      "path" $serviceMonitor.openMetrics.path
      "interval" $serviceMonitor.interval
      "basicAuth" (dict
        "username" (dict "name" $secret "key" "username")
        "password" (dict "name" $secret "key" "password")) -}}
{{- with $serviceMonitor.scrapeTimeout -}}
{{- $_ := set $endpoint "scrapeTimeout" . -}}
{{- end -}}
{{- if $https -}}
{{- with $serviceMonitor.tlsConfig -}}
{{- $_ := set $endpoint "tlsConfig" . -}}
{{- end -}}
{{- end -}}
{{- $endpoints = append $endpoints $endpoint -}}
{{- end -}}
{{- if .jmx.exporter.enabled -}}
{{- $endpoint := dict "port" "jmx-exporter" "interval" $serviceMonitor.interval -}}
{{- with $serviceMonitor.scrapeTimeout -}}
{{- $_ := set $endpoint "scrapeTimeout" . -}}
{{- end -}}
{{- $endpoints = append $endpoints $endpoint -}}
{{- end -}}
{{- if not $endpoints -}}
{{- fail "A ServiceMonitor needs something to scrape: keep `serviceMonitor.openMetrics.enabled`, run the `jmx.exporter` sidecar, or describe the scrape yourself in `serviceMonitor.endpoints`." -}}
{{- end -}}
{{- toYaml $endpoints -}}
{{- end -}}
{{- end }}

{{/*
The settings of a values block as they apply to one role, with that role's
overrides on top, at any depth. The deep copy is what keeps one role's
overrides out of the other's, since omit copies only the top level and the
nested maps below it still belong to the values. Takes `block` and `role`.
Returns YAML, so call it through fromYaml.
*/}}
{{- define "trino.roleConfig" -}}
{{- $block := .block | default dict -}}
{{- mergeOverwrite (deepCopy (omit $block "coordinator" "worker")) (index $block .role | default dict) | toYaml -}}
{{- end }}

{{/*
The `type` of an optional config block like `accessControl`, or an empty string
when neither the block nor its type is set. Comparing an unset value with a
string fails on Helm 3.7 and older, so every type comparison goes through this.
Takes the block, for example `.Values.resourceGroups`.
*/}}
{{- define "trino.configType" -}}
{{- get (. | default dict) "type" -}}
{{- end }}

{{/*
Fail on a key set in a role's service overrides that the role's Service cannot
apply, so that the value is not silently ignored. Takes `role`, `overrides` and
`supported`.
*/}}
{{- define "trino.checkServiceOverrides" -}}
{{- range $key := keys (.overrides | default dict) -}}
{{- if not (has $key $.supported) -}}
{{- fail (printf "service.%s.%s is not supported, the service settings that can differ per role are: %s" $.role $key (join ", " $.supported)) -}}
{{- end -}}
{{- end -}}
{{- end }}

{{/*
The access control settings as they apply to workers. Graceful shutdown needs
the file based access control on every worker to permit the shutdown request,
so when it is enabled and nothing else is configured, the settings are the
config map type holding only the generated rules file. Takes the root context.
Returns YAML, so call it through fromYaml.
*/}}
{{- define "trino.workerAccessControl" -}}
{{- $accessControl := include "trino.roleConfig" (dict "block" .Values.accessControl "role" "worker") | fromYaml -}}
{{- if and (not $accessControl) .Values.worker.gracefulShutdown.enabled -}}
{{- $_ := set $accessControl "type" "configmap" -}}
{{- $_ := set $accessControl "configFile" "graceful-shutdown-rules.json" -}}
{{- end -}}
{{- toYaml $accessControl -}}
{{- end }}

{{/*
The worker rules file with the permissions on system information that the
shutdown request needs merged into the rules the user configured. Trino reads
one access control document, so this is a merge of the `system_information`
rules and not a second file.

Both read and write are granted. The request itself only writes, but the first
rule matching a user decides, so a rule granting write alone would answer every
management read for that user with a denial, the metrics endpoint included.

A rule naming the shutdown user and nothing else gets the permissions added to
it, so the document keeps the shape the user gave it. Otherwise the generated
rule goes first, which takes nothing away from that user, since read and write
are all there is to grant. Takes the root context, returns the document as
JSON.
*/}}
{{- define "trino.workerAccessControlRules" -}}
{{- $accessControl := include "trino.workerAccessControl" . | fromYaml -}}
{{- $rulesFile := $accessControl.configFile | default "rules.json" -}}
{{- $document := index ($accessControl.rules | default dict) $rulesFile | default "{}" | fromJson -}}
{{- $user := .Values.worker.gracefulShutdown.user -}}
{{- $rules := list -}}
{{- $granted := false -}}
{{- range $rule := $document.system_information | default list -}}
{{- $merged := $rule -}}
{{- if and (eq ($rule.user | default "") $user) (not $rule.role) (not $rule.group) -}}
{{- $granted = true -}}
{{- $merged = set (deepCopy $rule) "allow" (concat ($rule.allow | default list) (list "read" "write") | uniq | sortAlpha) -}}
{{- end -}}
{{- $rules = append $rules $merged -}}
{{- end -}}
{{- if not $granted -}}
{{- $rules = prepend $rules (dict "user" $user "allow" (list "read" "write")) -}}
{{- end -}}
{{- set $document "system_information" $rules | toPrettyJson -}}
{{- end }}
