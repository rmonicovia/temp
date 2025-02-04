{{- define "render" -}}
{{- $ := deepCopy (first .) -}}
{{- $valuesDef := deepCopy $.Values.def  -}}
{{- $tplName := index . 1 -}}
{{- $apps := $.Values.forApps | default (dict $.Chart.Name $valuesDef ) -}}

{{ range $appName, $app := $apps }}
{{- $appName = ($appName | trunc 63 | trimSuffix "-") -}}
{{- $appName = ternary (printf "%s-%s" $.Chart.Name $appName) $appName (ne $.Chart.Name $appName) -}}
{{- $app = merge $app $valuesDef (dict "name" $appName) -}}
{{- $_ := set $.Values "def" $app -}}
{{- include $tplName $ }}
---
{{""}}
{{- end -}}
{{- end -}}



{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "chart.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}



{{/*
Common labels
*/}}
{{- define "chart.labels" -}}
helm.sh/chart: {{ include "chart.chart" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}


{{- define "selectorLabels" -}}
{{ if .Values.azure -}}
{{- include "kubernetes.selectorLabels" . -}}
{{- else -}}
{{- include "openshift.selectorLabels" . -}}
{{- end -}}
{{- end -}}


{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "chart.fullname" -}}
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
Create the name of the service account to use
*/}}
{{- define "chart.serviceAccountName" -}}
{{- if .Values.def.serviceAccount.create }}
{{- default (include "chart.fullname" .) .Values.def.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.def.serviceAccount.name }}
{{- end }}
{{- end }}
