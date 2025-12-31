{{/*
Expand the name of the chart.
*/}}
{{- define "postgresql-simple.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
*/}}
{{- define "postgresql-simple.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}

{{/*
PostgreSQL deployment name - simple
*/}}
{{- define "postgresql-simple.postgresql.name" -}}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
PgBouncer deployment name - simple
*/}}
{{- define "postgresql-simple.pgbouncer.name" -}}
{{- printf "%s-pgbouncer" .Release.Name | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "postgresql-simple.labels" -}}
helm.sh/chart: {{ include "postgresql-simple.name" . }}-{{ .Chart.Version | replace "+" "_" }}
{{ include "postgresql-simple.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "postgresql-simple.selectorLabels" -}}
app.kubernetes.io/name: {{ include "postgresql-simple.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Generate password if not provided
*/}}
{{- define "postgresql-simple.password" -}}
{{- if .Values.postgresql.password }}
{{- .Values.postgresql.password }}
{{- else }}
{{- randAlphaNum 32 }}
{{- end }}
{{- end }}

