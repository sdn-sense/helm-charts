{{/*
Define Deployment image
*/}}
{{- define "deploymentimage" -}}
{{- if .Values.image }}
{{- if .Values.image.image }}
{{- printf "sdnsense/siterm-agent:%s" .Values.image.image }}
{{- else }}
{{- printf "sdnsense/siterm-agent:dev" }}
{{- end }}
{{- else }}
{{- printf "sdnsense/siterm-agent:dev" }}
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
{{- printf "2"}}
{{- end }}
{{- end }}

{{- define "cpuRequest" -}}
{{- if .Values.cpuRequest }}
{{- toString .Values.cpuRequest }}
{{- else }}
{{- printf "600m"}}
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
{{- printf "1Gi"}}
{{- end }}
{{- end }}

{{/*
Expand the name of the chart.
*/}}

{{- define "sitermagent.truncname" -}}
{{- if .Values.md5 }}
{{- if eq .Values.deploymentType "Deployment" }}
{{- printf "%s-conf-%s" .Chart.Name .Values.md5 | replace "_" "-" | trunc 53 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-conf-%s" .Chart.Name .Values.deploymentType | replace "_" "-" | trunc 53 | trimSuffix "-" | lower }}
{{- end }}
{{- else }}
{{- printf "%s-conf-%s" .Chart.Name .Values.deploymentType | replace "_" "-" | trunc 53 | trimSuffix "-" | lower }}
{{- end }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 53 chars because some Kubernetes name fields are limited to this (by the DNS naming spec) (e.g. max is 63, we leave 10chars).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "sitermagent.fullname" -}}
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
Common labels
*/}}
{{- define "sitermagent.labels" -}}
helm.sh/chart: {{ include "sitermagent.chart" . }}
{{ include "sitermagent.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "sitermagent.selectorLabels" -}}
app.kubernetes.io/name: {{ include "sitermagent.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "sitermagent.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "sitermagent.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Security Context for the deployment
*/}}
{{- define "sitermagent.SecurityContext" -}}
{{- if .Values.securityContext -}}
{{ toYaml .Values.securityContext }}
{{- else -}}
capabilities:
  add:
  - NET_ADMIN
{{- end }}
{{- end }}

{{/*
Evaluate whether logstorage.enabled is true
*/}}
{{- define "sitermagent.logstorageEnabled" -}}
{{- $enabled := false }}
{{- if and (not (kindIs "invalid" .Values.logstorage)) (kindIs "map" .Values.logstorage) }}
  {{- if hasKey .Values.logstorage "enabled" }}
    {{- $enabled = .Values.logstorage.enabled }}
  {{- end }}
{{- end }}
{{- ternary "true" "false" $enabled }}
{{- end }}

{{/*
Validation check: DaemonSet cannot be used if logstorage.enabled is true
*/}}
{{- define "sitermagent.validateDeploymentType" -}}
{{- $logEnabled := (include "sitermagent.logstorageEnabled" .) | trim | eq "true" }}
{{- if and (eq .Values.deploymentType "DaemonSet") $logEnabled }}
  {{- fail "Error: 'DaemonSet' deployment type cannot be used when 'logstorage.enabled' is true. Please disable logstorage or change deploymentType to 'Deployment'." }}
{{- end }}
{{- end }}