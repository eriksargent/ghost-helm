{{/*
Expand the name of the chart.
*/}}
{{- define "ghost-helm.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "ghost-helm.fullname" -}}
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
{{- define "ghost-helm.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "ghost-helm.labels" -}}
helm.sh/chart: {{ include "ghost-helm.chart" . }}
{{ include "ghost-helm.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "ghost-helm.selectorLabels" -}}
app.kubernetes.io/name: {{ include "ghost-helm.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Ghost selector labels
*/}}
{{- define "ghost-helm.ghostSelectorLabels" -}}
app.kubernetes.io/name: {{ include "ghost-helm.name" . }}-ghost
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Database selector labels
*/}}
{{- define "ghost-helm.dbSelectorLabels" -}}
app.kubernetes.io/name: {{ include "ghost-helm.name" . }}-db
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
ActivityPub selector labels
*/}}
{{- define "ghost-helm.activitypubSelectorLabels" -}}
app.kubernetes.io/name: {{ include "ghost-helm.name" . }}-activitypub
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}
