{{/*
Expand the name of the chart.
*/}}
{{- define "monitor.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "monitor.fullname" -}}
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
{{- define "monitor.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "monitor.labels" -}}
helm.sh/chart: {{ include "monitor.chart" . }}
{{ include "monitor.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- with .Values.global.labels }}
{{- toYaml . }}
{{- end }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "monitor.selectorLabels" -}}
app.kubernetes.io/name: {{ include "monitor.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "monitor.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "monitor.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Namespace name
*/}}
{{- define "monitor.namespace" -}}
{{- default "monitoring" .Values.namespace.name }}
{{- end }}

{{/*
Prometheus fullname (from kube-prometheus-stack)
*/}}
{{- define "monitor.prometheus.fullname" -}}
{{- printf "%s-kube-prometheus-prometheus" .Release.Name }}
{{- end }}

{{/*
Grafana fullname (from kube-prometheus-stack)
*/}}
{{- define "monitor.grafana.fullname" -}}
{{- printf "%s-kube-prometheus-grafana" .Release.Name }}
{{- end }}

{{/*
Grafana service name
*/}}
{{- define "monitor.grafana.serviceName" -}}
{{- printf "%s-kube-prometheus-grafana" .Release.Name }}
{{- end }}

{{/*
Grafana ingress hostname helper
Obtém o hostname do values. Se null, deve ser passado via --set ou script helper
*/}}
{{- define "monitor.grafana.ingress.hostname" -}}
{{- if .Values.grafanaIngress.hostname }}
{{- .Values.grafanaIngress.hostname }}
{{- else }}
{{- "s4125" }}
{{- end }}
{{- end }}

{{/*
Grafana ingress hostname
Construi o hostname automaticamente: grafana.[hostname].eficify.cloud
Ou usa o host customizado se especificado
*/}}
{{- define "monitor.grafana.ingress.host" -}}
{{- if .Values.grafanaIngress.host }}
{{- .Values.grafanaIngress.host }}
{{- else }}
{{- $hostname := include "monitor.grafana.ingress.hostname" . }}
{{- printf "grafana.%s.eficify.cloud" $hostname }}
{{- end }}
{{- end }}

{{/*
Grafana ingress annotations
*/}}
{{- define "monitor.grafana.ingress.annotations" -}}
{{- if .Values.grafanaIngress.annotations }}
{{- toYaml .Values.grafanaIngress.annotations }}
{{- end }}
{{- if .Values.grafanaIngress.tls.enabled }}
{{- if .Values.certManager.clusterIssuer }}
cert-manager.io/cluster-issuer: {{ .Values.certManager.clusterIssuer }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Grafana ingress TLS hosts
*/}}
{{- define "monitor.grafana.ingress.tlsHosts" -}}
{{- if .Values.grafanaIngress.tls.enabled }}
- {{ include "monitor.grafana.ingress.host" . }}
{{- end }}
{{- end }}

{{/*
Grafana ingress TLS secret name
*/}}
{{- define "monitor.grafana.ingress.tlsSecret" -}}
{{- if .Values.grafanaIngress.tls.secretName }}
{{- .Values.grafanaIngress.tls.secretName }}
{{- else }}
{{- printf "%s-grafana-tls" (include "monitor.fullname" .) }}
{{- end }}
{{- end }}

{{/*
Storage class helper
*/}}
{{- define "monitor.storageClass" -}}
{{- if .Values.storage.storageClass }}
{{- .Values.storage.storageClass }}
{{- else }}
{{- "" }}
{{- end }}
{{- end }}

{{/*
Common annotations
*/}}
{{- define "monitor.annotations" -}}
{{- with .Values.global.annotations }}
{{- toYaml . }}
{{- end }}
{{- end }}

