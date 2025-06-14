{{/*
Define Deployment image
*/}}
{{- define "deploymentimage" -}}
{{- if .Values.image }}
{{- if .Values.image.image }}
{{- printf "sdnsense/siterm-debugger:%s" .Values.image.image }}
{{- else }}
{{- printf "sdnsense/siterm-debugger:dev" }}
{{- end }}
{{- else }}
{{- printf "sdnsense/siterm-debugger:dev" }}
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
{{- printf "16"}}
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
{{- printf "32Gi"}}
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
{{- printf "siterm-agent-conf-%s" .Values.md5 | replace "_" "-" | trunc 53 | trimSuffix "-" }}
{{- else }}
{{- printf "siterm-agent-conf-%s" .Values.deploymentType | replace "_" "-" | trunc 53 | trimSuffix "-" | lower }}
{{- end }}
{{- else }}
{{- printf "siterm-agent-conf-%s" .Values.deploymentType | replace "_" "-" | trunc 53 | trimSuffix "-" | lower }}
{{- end }}
{{- end }}

{{/*
Also defined siterm-debug chart name (this dir). This chart re-uses same certss and configmap names as sitermagent chart.
This is to ensure that the siterm-debug chart can be used with the same configuration as sitermagent.
*/}}
{{- define "sitermdebug.truncname" -}}
{{- $baseName := default .Chart.Name .Values.customPodName }}
{{- if .Values.md5 }}
{{- if eq .Values.deploymentType "Deployment" }}
{{- printf "%s-conf-%s" $baseName .Values.md5 | replace "_" "-" | trunc 53 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-conf-%s" $baseName .Values.deploymentType | replace "_" "-" | trunc 53 | trimSuffix "-" | lower }}
{{- end }}
{{- else }}
{{- printf "%s-conf-%s" $baseName .Values.deploymentType | replace "_" "-" | trunc 53 | trimSuffix "-" | lower }}
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
{{- $baseName := default .Chart.Name .Values.customPodName }}
{{- $name := default $baseName .Values.nameOverride }}
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
{{- define "sitermdebug.labels" -}}
helm.sh/chart: {{ include "sitermdebug.chart" . }}
{{ include "sitermdebug.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "sitermdebug.selectorLabels" -}}
app.kubernetes.io/name: {{ include "sitermdebug.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "sitermdebug.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "sitermdebug.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Security Context for the deployment
*/}}
{{- define "sitermdebug.SecurityContext" -}}
{{- if .Values.securityContext -}}
{{ toYaml .Values.securityContext }}
{{- else -}}
capabilities: {}
{{- end }}
{{- end }}

{{/*
hostNetwork default for the deployment
*/}}
{{- define "hostnetwork" -}}
{{- if hasKey .Values "hostNetwork" }}
{{ .Values.hostNetwork }}
{{- else }}
true
{{- end }}
{{- end }}

{{/*
hostPID default for the deployment
*/}}
{{- define "hostpid" -}}
{{- if hasKey .Values "hostPID" }}
{{ .Values.hostPID }}
{{- else }}
false
{{- end }}
{{- end }}

{{/*
Evaluate whether logstorage.enabled is true
*/}}
{{- define "sitermdebugger.logstorageEnabled" -}}
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
{{- define "sitermdebugger.validateDeploymentType" -}}
{{- $logEnabled := (include "sitermdebugger.logstorageEnabled" .) | trim | eq "true" }}
{{- if and (eq .Values.deploymentType "DaemonSet") $logEnabled }}
  {{- fail "Error: 'DaemonSet' deployment type cannot be used when 'logstorage.enabled' is true. Please disable logstorage or change deploymentType to 'Deployment'." }}
{{- end }}
{{- end }}