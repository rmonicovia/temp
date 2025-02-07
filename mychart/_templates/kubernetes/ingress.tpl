{{- define "tslmap" -}}
grupocasasbahia: []
casasbahia: []
viavarejo: []
pontofrio: []
extra: []
via: []
{{- end -}}

{{- define "internalIngressTLS.tpl" -}}
tls:
{{- range $secret, $hosts := . -}}
  {{- if $hosts -}}
  {{- $secret = printf "%s-%s" $secret "tls" }}
  - secretName: {{ $secret }}
    hosts:
      {{- toYaml $hosts | nindent 4 }}
  {{- end -}}
{{- end -}}
{{- end -}}

{{- define "tlsSecrets.tpl" -}}
{{- $secrets := fromYaml (include "tslmap" . ) -}}

{{- range $name, $ingress := .Values.def.ingresses -}}
{{- $domain := regexFind "[\\w\\-]+\\.com\\.br" $ingress.host | replace ".com.br" "" -}}
{{- if hasKey $secrets $domain -}}
{{- $hosts :=  index $secrets $domain -}}
{{- $hosts = append $hosts $ingress.host -}}
{{- $_ := set $secrets $domain $hosts -}}
{{- end -}}
{{- end -}}

{{- $tlsSecrets := fromYaml (include "internalIngressTLS.tpl" $secrets) -}}
{{- if $tlsSecrets.tls -}}
{{- toYaml $tlsSecrets -}}
{{- end -}}
{{- end -}}