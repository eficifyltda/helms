{{/*
Expand the name of the chart.
*/}}
{{- define "metabase.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
*/}}
{{- define "metabase.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "metabase.labels" -}}
helm.sh/chart: {{ include "metabase.name" . }}-{{ .Chart.Version | replace "+" "_" }}
{{ include "metabase.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "metabase.selectorLabels" -}}
app.kubernetes.io/name: {{ include "metabase.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Metabase deployment name
*/}}
{{- define "metabase.metabase.name" -}}
{{- printf "%s-metabase" .Release.Name | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
PostgreSQL deployment name
*/}}
{{- define "metabase.postgresql.name" -}}
{{- printf "%s-postgresql" .Release.Name | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Generate PostgreSQL password if not provided
*/}}
{{- define "metabase.postgresql.password" -}}
{{- if .Values.postgresql.password }}
{{- .Values.postgresql.password }}
{{- else }}
{{- randAlphaNum 32 }}
{{- end }}
{{- end }}

{{/*
PostgreSQL connection string
*/}}
{{- define "metabase.postgresql.connectionString" -}}
{{- printf "postgres://%s:%s@%s:%d/%s" .Values.postgresql.username (include "metabase.postgresql.password" .) (include "metabase.postgresql.name" .) .Values.postgresql.service.port .Values.postgresql.database }}
{{- end }}

