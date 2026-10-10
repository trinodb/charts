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
The settings of a values block as they apply to one role, with that role's
overrides on top, at any depth. The deep copy is what keeps one role's
overrides out of the other's, since omit copies only the top level and the
nested maps below it still belong to the values. Takes `block` and `role`.
Returns YAML, so call it through fromYaml.
*/}}
{{- define "trino.roleConfig" -}}
{{- mergeOverwrite (deepCopy (omit .block "coordinator" "worker")) (index .block .role | default dict) | toYaml -}}
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
