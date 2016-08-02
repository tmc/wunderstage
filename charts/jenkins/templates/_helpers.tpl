{{define "fullname"}}
{{- $name := default "jenkins" .Values.nameOverride -}}
{{printf "%s-%s" .Release.Name $name | trunc 24 -}}
{{end}}
{{define "proxyname"}}
{{- $name := default "proxy" .Values.proxyNameOverride -}}
{{printf "%s-%s" .Release.Name $name | trunc 24 -}}
{{end}}
