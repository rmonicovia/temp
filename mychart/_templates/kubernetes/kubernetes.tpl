{{/*
Selector labels
*/}}
{{- define "kubernetes.selectorLabels" -}}
app.kubernetes.io/instance: {{ .Values.def.name }}
app.kubernetes.io/name: {{ .Values.def.name }}
{{- end }}