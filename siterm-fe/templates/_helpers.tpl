{{/*
Define Deployment image
*/}}
{{- define "deploymentimage" -}}
{{- if .Values.image }}
{{- if .Values.image.image }}
{{- printf "sdnsense/siterm-fe:%s" .Values.image.image }}
{{- else }}
{{- printf "sdnsense/siterm-fe:1.5.33-rc01" }}
{{- end }}
{{- else }}
{{- printf "sdnsense/siterm-fe:1.5.33-rc01" }}
{{- end }}
{{- end }}

{{/*
Define Deployment pull policy
*/}}

{{- define "deploymentpullpolicy" -}}
{{- if .Values.image }}
{{- if .Values.image.pullPolicy }}
{{- printf "%s" .Values.image.pullPolicy }}
{{- else }}
{{- printf "Always"}}
{{- end }}
{{- else }}
{{- printf "Always"}}
{{- end }}
{{- end }}


{{/*
Define CPU and Memory Limits/Requests
*/}}
{{- define "cpulimit" -}}
{{- if .Values.cpuLimit }}
{{- toString .Values.cpuLimit }}
{{- else }}
{{- printf "4"}}
{{- end }}
{{- end }}

{{- define "cpuRequest" -}}
{{- if .Values.cpuRequest }}
{{- toString .Values.cpuRequest }}
{{- else }}
{{- printf "2"}}
{{- end }}
{{- end }}

{{- define "memorylimit" -}}
{{- if .Values.memoryLimit }}
{{- toString .Values.memoryLimit }}
{{- else }}
{{- printf "4Gi"}}
{{- end }}
{{- end }}

{{- define "memoryRequest" -}}
{{- if .Values.memoryRequest }}
{{- toString .Values.memoryRequest }}
{{- else }}
{{- printf "2Gi"}}
{{- end }}
{{- end }}


{{/*
Expand the name of the chart.
*/}}

{{- define "sitefe.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 53 | trimSuffix "-" }}
{{- end }}


{{- define "sitefe.truncname" -}}
{{- if .Values.md5 }}
{{- printf "%s-%s-%s" .Chart.Name .Values.sitename .Values.md5 | replace "_" "-" | trunc 53 | trimSuffix "-" | lower }}
{{- else }}
{{- printf "%s-conf-%s" .Chart.Name .Values.sitename | replace "_" "-" | trunc 53 | trimSuffix "-" | lower }}
{{- end }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 53 chars because some Kubernetes name fields are limited to this (by the DNS naming spec) (e.g. max is 63, we leave 10chars).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "sitefe.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 53 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 53 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 53 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "sitefe.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 53 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "sitefe.labels" -}}
helm.sh/chart: {{ include "sitefe.chart" . }}
{{ include "sitefe.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "sitefe.selectorLabels" -}}
app.kubernetes.io/name: {{ include "sitefe.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "sitefe.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "sitefe.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}
