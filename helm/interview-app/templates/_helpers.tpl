{{/* vim: set filetype=mustache: */}}

{{/*
Helper to validate that the TUM ID is set.
*/}}
{{- define "interview-app.validateTUMID" -}}
{{- if not .Values.tumid -}}
{{-   fail (printf "ERROR: Your TUM ID ('tumid') is not set or is empty in 'values.yaml'.") -}}
{{- end -}}
{{- end -}}

{{/*
Determine the namespace to use.
*/}}
{{- define "interview-app.namespace" -}}
{{- if .Values.namespace -}}
{{- .Values.namespace -}}
{{- else if .Values.tumid -}}
{{- printf "%s-devops26" .Values.tumid -}}
{{- else -}}
{{- "default" -}}
{{- end -}}
{{- end -}}

{{/*
Determine the ingress host.
*/}}
{{- define "interview-app.ingressHost" -}}
{{- if .Values.ingress.host -}}
{{- .Values.ingress.host -}}
{{- else -}}
{{- printf "ai-mock-interview-%s.stud.k8s.aet.cit.tum.de" .Values.tumid -}}
{{- end -}}
{{- end -}}

{{/*
Expand the name of the chart.
*/}}
{{- define "interview-app.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
*/}}
{{- define "interview-app.fullname" -}}
{{- if .Values.fullnameOverride -}}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- $name := default .Chart.Name .Values.nameOverride -}}
{{- if contains $name .Release.Name -}}
{{- .Release.Name | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}
{{- end -}}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "interview-app.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Common labels
*/}}
{{- define "interview-app.labels" -}}
helm.sh/chart: {{ include "interview-app.chart" . }}
{{ include "interview-app.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end -}}

{{/*
Selector labels
*/}}
{{- define "interview-app.selectorLabels" -}}
app.kubernetes.io/name: {{ include "interview-app.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end -}}
