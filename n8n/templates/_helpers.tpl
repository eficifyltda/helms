{{/*
Expand the name of the chart.
*/}}
{{- define "n8n.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
*/}}
{{- define "n8n.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "n8n.labels" -}}
helm.sh/chart: {{ include "n8n.name" . }}-{{ .Chart.Version | replace "+" "_" }}
{{ include "n8n.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "n8n.selectorLabels" -}}
app.kubernetes.io/name: {{ include "n8n.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
n8n deployment name
*/}}
{{- define "n8n.n8n.name" -}}
{{- printf "%s-n8n" .Release.Name | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
PostgreSQL deployment name
*/}}
{{- define "n8n.postgresql.name" -}}
{{- printf "%s-postgresql" .Release.Name | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Generate PostgreSQL password if not provided
*/}}
{{- define "n8n.postgresql.password" -}}
{{- if .Values.postgresql.password }}
{{- .Values.postgresql.password }}
{{- else }}
{{- randAlphaNum 32 }}
{{- end }}
{{- end }}

{{/*
PostgreSQL connection string
*/}}
{{- define "n8n.postgresql.connectionString" -}}
{{- printf "postgres://%s:%s@%s:%d/%s" .Values.postgresql.username (include "n8n.postgresql.password" .) (include "n8n.postgresql.name" .) .Values.postgresql.service.port .Values.postgresql.database }}
{{- end }}

