{{/*
Expands to "true" if second arg is a key in first parameter (a list)
*/}}
{{- define "someItemHasKey" -}}
  {{- $items := index . 0 }}
  {{- $key_name := index . 1 }}

  {{- range $items -}}
    {{- if hasKey . $key_name -}}
      {{ true }}
      {{- break -}}
    {{- end -}}
  {{- end -}}
{{- end -}}
