{{/*
Expand the name of the chart.
*/}}
{{- define "shrtbred.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "shrtbred.fullname" -}}
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
{{- define "shrtbred.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "shrtbred.labels" -}}
helm.sh/chart: {{ include "shrtbred.chart" . }}
{{ include "shrtbred.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "shrtbred.selectorLabels" -}}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}



{{/*
app configuration
*/}}
{{- define "app.name" -}}
{{- default "shrtbred-app" .Values.app.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{- define "app.fullname" -}}
{{- default "shrtbred-app" .Values.app.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
app labels
*/}}
{{- define "app.labels" -}}
{{ include "shrtbred.selectorLabels" . }}
app.kubernetes.io/name: {{ include "app.name" .}}
{{- end }}


{{/*
Create the name of the app service account to use
*/}}
{{- define "app.serviceAccountName" -}}
{{- if .Values.app.serviceAccount.create }}
{{- default (include "app.fullname" .) .Values.app.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.app.serviceAccount.name }}
{{- end }}
{{- end }}



{{/*
nginx configuration
*/}}
{{- define "nginx.name" -}}
{{- default "shrtbred-nginx" .Values.nginx.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{- define "nginx.fullname" -}}
{{- default "shrtbred-nginx" .Values.nginx.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
nginx labels
*/}}
{{- define "nginx.labels" -}}
{{ include "shrtbred.selectorLabels" . }}
app.kubernetes.io/name: {{ include "nginx.name" .}}
{{- end }}


{{/*
Create the name of the nginx service account to use
*/}}
{{- define "nginx.serviceAccountName" -}}
{{- if .Values.nginx.serviceAccount.create }}
{{- default (include "nginx.fullname" .) .Values.nginx.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.nginx.serviceAccount.name }}
{{- end }}
{{- end }}
