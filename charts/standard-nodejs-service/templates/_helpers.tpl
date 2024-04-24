{{/*
Expand the name of the chart.
*/}}
{{- define "standard-service.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "standard-service.fullname" -}}
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
{{- define "standard-service.chart-version" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "standard-service.labels" -}}
{{ include "standard-service.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "standard-service.selectorLabels" -}}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "standard-service.serviceAccountName" -}}
{{- if .Values.rbac.serviceAccount.create }}
{{- default (include "standard-service.fullname" .) .Values.rbac.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.rbac.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Create a comma separated list of secrets for reloader to watch based on extraEnvs that source their values
from secrets

The first function generates a list and excludes non-secret related env vars and the second function strips the trailing
comma from the first process
*/}}
{{- define "standard-service.reloaderSecrets" -}}
{{ range .Values.extraEnv -}}
{{- if hasKey . "valueFrom" -}}
{{ .valueFrom.secretKeyRef.name }},
{{- end }}
{{- end }}
{{- end }}

{{- define "standard-service.reloaderSecretsList" -}}
{{ include "standard-service.reloaderSecrets" . | trimSuffix "," }}
{{- end }}

{{/*
Create a comma separated list of log_processing_rules for Datadog Logs

The first function generates a list and the second function strips the trailing
comma from the first process
*/}}

{{- define "standard-service.datadog.logProcessingRules" }}
{{- range .Values.datadog.logConfig.rules }}
{
  "type": "{{ .type }}",
  "name": "{{ .name }}",
  "pattern" : "{{ .pattern }}"
},
{{- end }}
{{- end }}

{{- define "standard-service.datadog.logProcessingRulesList" -}}
{{- include "standard-service.datadog.logProcessingRules" . | trimSuffix "," }}
{{- end }}
