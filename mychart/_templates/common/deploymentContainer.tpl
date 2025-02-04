{{- define "deployment.container.image" }}
{{- $image := .Values.def.deployment.container.image -}}
{{- $repository := (default .Chart.Name $image.repository) -}}
"{{- $image.registry }}/{{ $repository}}/{{ .Chart.Name }}:{{ $image.tag | default .Chart.Version }}"
{{- end }}


{{- define "deploymentContainer.tpl" -}}
{{- $deployment := .Values.def.deployment -}}
{{- $container:= $deployment.container -}}

{{- with $deployment.imagePullSecrets }}
imagePullSecrets:
  {{- toYaml . | nindent 2 }}
{{- end -}}
{{- with $deployment.securityContext -}}
securityContext:
  {{- toYaml . | nindent 2 }}
{{- end }}
containers:
- name: {{ .Values.def.name }}
  {{- with $container.securityContext }}
  securityContext:
    {{- toYaml . | nindent 4 }}
  {{- end }}
  image: {{ include "deployment.container.image" . }}
  imagePullPolicy: {{ $container.image.pullPolicy }}
  ports:
    {{- range $servicePort := .Values.def.service.ports }}
    - containerPort: {{ $servicePort }}
      protocol: TCP
    {{- end }}
  resources:
    {{- toYaml $container.resources | nindent 4 }}
  envFrom:
    - configMapRef:
        name: {{ .Values.def.name }}
    {{- range $container.configMaps }}
    - configMapRef:
        name: {{ . }}
    {{- end }}
    {{- range $container.secrets }}
    - secretRef:
        name: {{ . }}
    {{- end }}
  livenessProbe:
    {{- toYaml $container.livenessProbe | nindent 4 }}
  readinessProbe:
    {{- toYaml $container.readinessProbe | nindent 4 }}
  env:
    - name: POD_NAME
      valueFrom:
        fieldRef:
          fieldPath: metadata.name
{{- end -}}