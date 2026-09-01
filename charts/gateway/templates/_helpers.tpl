{{/*
Expand the name of the chart.
*/}}
{{- define "trino-gateway.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "trino-gateway.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "trino-gateway.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "trino-gateway.labels" -}}
helm.sh/chart: {{ include "trino-gateway.chart" . }}
{{ include "trino-gateway.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- if .Values.commonLabels }}
{{ tpl (toYaml .Values.commonLabels) . }}
{{- end }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "trino-gateway.selectorLabels" -}}
app.kubernetes.io/name: {{ include "trino-gateway.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "trino-gateway.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "trino-gateway.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
The HTTP port the gateway listens on. Defaults to the Trino Gateway default,
so that the port is only present in the rendered configuration file when it is
set explicitly.
*/}}
{{- define "trino-gateway.httpPort" -}}
{{- index .Values.config.serverConfig "http-server.http.port" | default 8080 }}
{{- end }}

{{/*
The HTTPS port the gateway listens on. Defaults to the Trino Gateway default,
so that the port is only present in the rendered configuration file when it is
set explicitly.
*/}}
{{- define "trino-gateway.httpsPort" -}}
{{- index .Values.config.serverConfig "http-server.https.port" | default 8443 }}
{{- end }}
