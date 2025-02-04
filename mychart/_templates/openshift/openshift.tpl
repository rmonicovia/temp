{{- define "openshift.selectorLabels" -}}
app: {{ .Values.def.name }}
{{- end -}}