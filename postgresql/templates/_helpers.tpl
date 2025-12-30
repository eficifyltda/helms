{{/*
Expand the name of the chart.
*/}}
{{- define "postgresql.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
*/}}
{{- define "postgresql.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "postgresql.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "postgresql.labels" -}}
helm.sh/chart: {{ include "postgresql.chart" . }}
{{ include "postgresql.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "postgresql.selectorLabels" -}}
app.kubernetes.io/name: {{ include "postgresql.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
PostgreSQL labels
*/}}
{{- define "postgresql.postgresql.labels" -}}
{{ include "postgresql.labels" . }}
app.kubernetes.io/component: postgresql
{{- end }}

{{/*
PostgreSQL selector labels
*/}}
{{- define "postgresql.postgresql.selectorLabels" -}}
{{ include "postgresql.selectorLabels" . }}
app.kubernetes.io/component: postgresql
{{- end }}

{{/*
PgBouncer labels
*/}}
{{- define "postgresql.pgbouncer.labels" -}}
{{ include "postgresql.labels" . }}
app.kubernetes.io/component: pgbouncer
{{- end }}

{{/*
PgBouncer selector labels
*/}}
{{- define "postgresql.pgbouncer.selectorLabels" -}}
{{ include "postgresql.selectorLabels" . }}
app.kubernetes.io/component: pgbouncer
{{- end }}

{{/*
PostgreSQL Exporter labels
*/}}
{{- define "postgresql.exporter.labels" -}}
{{ include "postgresql.labels" . }}
app.kubernetes.io/component: postgres-exporter
{{- end }}

{{/*
PostgreSQL Exporter selector labels
*/}}
{{- define "postgresql.exporter.selectorLabels" -}}
{{ include "postgresql.selectorLabels" . }}
app.kubernetes.io/component: postgres-exporter
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "postgresql.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "postgresql.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
PostgreSQL connection string
*/}}
{{- define "postgresql.connectionString" -}}
postgresql://{{ .Values.postgresql.username }}:{{ .Values.postgresql.password }}@{{ include "postgresql.fullname" . }}-postgresql:{{ .Values.postgresql.service.port }}/{{ .Values.postgresql.database }}
{{- end }}

{{/*
Generate random password if not provided
*/}}
{{- define "postgresql.password" -}}
{{- if .Values.postgresql.password }}
{{- .Values.postgresql.password }}
{{- else }}
{{- randAlphaNum 32 }}
{{- end }}
{{- end }}

{{/*
Read Replica labels
*/}}
{{- define "postgresql.readReplica.labels" -}}
{{ include "postgresql.labels" . }}
app.kubernetes.io/component: read-replica
{{- end }}

{{/*
Read Replica selector labels
*/}}
{{- define "postgresql.readReplica.selectorLabels" -}}
{{ include "postgresql.selectorLabels" . }}
app.kubernetes.io/component: read-replica
{{- end }}

{{/*
Map preset aliases (dev -> small, stg -> medium)
*/}}
{{- define "postgresql.preset.map" -}}
{{- if eq .Values.postgresql.sizePreset "dev" }}
{{- "small" }}
{{- else if eq .Values.postgresql.sizePreset "stg" }}
{{- "medium" }}
{{- else }}
{{- .Values.postgresql.sizePreset }}
{{- end }}
{{- end }}

{{/*
Check if backup should be enabled (disabled for dev/stg)
*/}}
{{- define "postgresql.backup.enabled" -}}
{{- $preset := include "postgresql.preset.map" . }}
{{- if or (eq $preset "dev") (eq $preset "stg") }}
{{- false }}
{{- else }}
{{- .Values.backup.enabled }}
{{- end }}
{{- end }}

{{/*
Check if replication should be enabled (disabled for dev/stg)
*/}}
{{- define "postgresql.replication.enabled" -}}
{{- $preset := include "postgresql.preset.map" . }}
{{- if or (eq $preset "dev") (eq $preset "stg") }}
{{- false }}
{{- else }}
{{- .Values.postgresql.replication.enabled }}
{{- end }}
{{- end }}

{{/*
Get PostgreSQL resources based on preset or custom
*/}}
{{- define "postgresql.resources" -}}
{{- if eq .Values.postgresql.sizePreset "custom" }}
{{- toYaml .Values.postgresql.resources }}
{{- else }}
{{- $mappedPreset := include "postgresql.preset.map" . }}
{{- $preset := index .Values.sizePresets $mappedPreset }}
{{- toYaml $preset.resources }}
{{- end }}
{{- end }}

{{/*
Get PostgreSQL persistence size based on preset or custom
*/}}
{{- define "postgresql.persistence.size" -}}
{{- if eq .Values.postgresql.sizePreset "custom" }}
{{- .Values.postgresql.persistence.size }}
{{- else }}
{{- $mappedPreset := include "postgresql.preset.map" . }}
{{- $preset := index .Values.sizePresets $mappedPreset }}
{{- $preset.persistence.size }}
{{- end }}
{{- end }}

{{/*
Get PostgreSQL config value by key based on preset or custom
*/}}
{{- define "postgresql.config.value" -}}
{{- $key := index . 0 }}
{{- $context := index . 1 }}
{{- if eq $context.Values.postgresql.sizePreset "custom" }}
{{- index $context.Values.postgresql.config $key }}
{{- else }}
{{- $mappedPreset := include "postgresql.preset.map" $context }}
{{- $preset := index $context.Values.sizePresets $mappedPreset }}
{{- index $preset.config $key }}
{{- end }}
{{- end }}

{{/*
Get PostgreSQL persistence storageClass based on preset or custom
*/}}
{{- define "postgresql.persistence.storageClass" -}}
{{- if eq .Values.postgresql.sizePreset "custom" }}
{{- .Values.postgresql.persistence.storageClass }}
{{- else }}
{{- .Values.postgresql.persistence.storageClass | default "" }}
{{- end }}
{{- end }}

{{/*
Get PostgreSQL persistence accessMode based on preset or custom
*/}}
{{- define "postgresql.persistence.accessMode" -}}
{{- if eq .Values.postgresql.sizePreset "custom" }}
{{- .Values.postgresql.persistence.accessMode }}
{{- else }}
{{- .Values.postgresql.persistence.accessMode | default "ReadWriteOnce" }}
{{- end }}
{{- end }}

{{/*
Get service type (public or cluster)
*/}}
{{- define "postgresql.service.type" -}}
{{- if .Values.postgresql.exposePublicly.enabled }}
{{- .Values.postgresql.exposePublicly.serviceType }}
{{- else }}
{{- .Values.postgresql.service.type }}
{{- end }}
{{- end }}

{{/*
Get service port (validate not 5432 when public)
*/}}
{{- define "postgresql.service.port" -}}
{{- if .Values.postgresql.exposePublicly.enabled }}
{{- if eq (toString .Values.postgresql.exposePublicly.port) "5432" }}
{{- fail "Porta 5432 não é permitida quando exposta publicamente. Use uma porta diferente (ex: 5433)" }}
{{- end }}
{{- .Values.postgresql.exposePublicly.port }}
{{- else }}
{{- .Values.postgresql.service.port }}
{{- end }}
{{- end }}

{{/*
Generate random hostname for Ingress when SSL is enabled
Format: [random]-db.[hostname-server].eficify.cloud
*/}}
{{- define "postgresql.ingress.hostname" -}}
{{- $host := (index .Values.ingress.hosts 0).host }}
{{- if and .Values.postgresql.ssl.enabled (not $host) }}
{{- $random := randAlphaNum 8 | lower }}
{{- $hostnameServer := .Values.ingress.hostnameServer }}
{{- if not $hostnameServer }}
{{- $hostnameServer = "k8s" }}
{{- end }}
{{- printf "%s-db.%s.eficify.cloud" $random $hostnameServer }}
{{- else if $host }}
{{- $host }}
{{- else }}
{{- "postgresql.example.com" }}
{{- end }}
{{- end }}

{{/*
Check if Ingress should be enabled (auto-enable when SSL is enabled)
*/}}
{{- define "postgresql.ingress.enabled" -}}
{{- if .Values.postgresql.ssl.enabled }}
{{- true }}
{{- else }}
{{- .Values.ingress.enabled }}
{{- end }}
{{- end }}

