{{/*
Expand the name of the chart.
*/}}
{{- define "app-js.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
*/}}
{{- define "app-js.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "app-js.labels" -}}
helm.sh/chart: {{ include "app-js.name" . }}-{{ .Chart.Version | replace "+" "_" }}
{{ include "app-js.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "app-js.selectorLabels" -}}
app.kubernetes.io/name: {{ include "app-js.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Backend deployment name
*/}}
{{- define "app-js.backend.name" -}}
{{- printf "%s-backend" .Release.Name | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Frontend deployment name
*/}}
{{- define "app-js.frontend.name" -}}
{{- printf "%s-frontend" .Release.Name | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
PostgreSQL deployment name
*/}}
{{- define "app-js.postgresql.name" -}}
{{- printf "%s-postgresql" .Release.Name | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Generate PostgreSQL password if not provided
*/}}
{{- define "app-js.postgresql.password" -}}
{{- if .Values.postgresql.password }}
{{- .Values.postgresql.password }}
{{- else }}
{{- randAlphaNum 32 }}
{{- end }}
{{- end }}

