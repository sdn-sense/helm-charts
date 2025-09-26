{{- /* 
Define default registry if not set in values.yaml
*/ -}}
{{- define "defaultregistry" -}}
{{- if .Values.image }}
{{- if .Values.image.registry }}
{{- printf "%s" .Values.image.registry }}
{{- else }}
{{- printf "quay.io" }}
{{- end }}
{{- else }}
{{- printf "quay.io" }}
{{- end }}
{{- end }}

{{/*
Define Deployment image
*/}}
{{- define "deploymentimage" -}}
{{- if .Values.image }}
{{- if .Values.image.image }}
{{- printf "sdnsense/siterm-debugger:%s" .Values.image.image }}
{{- else }}
{{- printf "sdnsense/siterm-debugger:1.5.60-rc02" }}
{{- end }}
{{- else }}
{{- printf "sdnsense/siterm-debugger:1.5.60-rc02" }}
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
{{- printf "200m"}}
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
{{- printf "512Mi"}}
{{- end }}
{{- end }}

{{/*
Expand the name of the chart.
*/}}

{{- define "sitermagent.truncname" -}}
{{- if .Values.md5 }}
{{- if or (eq .Values.deploymentType "StatefulSet") (eq .Values.deploymentType "Deployment") }}
{{- printf "siterm-agent-conf-%s" .Values.md5 | replace "_" "-" | trunc 53 | trimSuffix "-" }}
{{- else }}
{{- printf "siterm-agent-conf-%s" .Values.deploymentType | replace "_" "-" | trunc 53 | trimSuffix "-" | lower }}
{{- end }}
{{- else }}
{{- printf "siterm-agent-conf-%s" .Values.deploymentType | replace "_" "-" | trunc 53 | trimSuffix "-" | lower }}
{{- end }}
{{- end }}

{{/*
Also defined siterm-debug chart name (this dir). This chart re-uses same certs and configmap names as sitermagent chart.
This is to ensure that the siterm-debug chart can be used with the same configuration as sitermagent.
*/}}
{{- define "sitermdebugger.truncname" -}}
{{- $baseName := default .Chart.Name .Values.customPodName }}
{{- if .Values.md5 }}
{{- if or (eq .Values.deploymentType "StatefulSet") (eq .Values.deploymentType "Deployment") }}
{{- printf "%s-conf-%s" $baseName .Values.md5 | replace "_" "-" | trunc 53 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-conf-%s" $baseName .Values.deploymentType | replace "_" "-" | trunc 53 | trimSuffix "-" | lower }}
{{- end }}
{{- else }}
{{- printf "%s-conf-%s" $baseName .Values.deploymentType | replace "_" "-" | trunc 53 | trimSuffix "-" | lower }}
{{- end }}
{{- end }}

{{/*
Create a default deployment/statefulset/daemonset app name used in matching pods/deployments.
We truncate at 43 chars because some Kubernetes name fields are limited to this (by the DNS naming spec) (e.g. max is 63, we leave 20chars).
*/}}
{{- define "sitermdebugger.name" -}}
{{- $baseName := default .Chart.Name .Values.customPodName }}
{{- if .Values.md5 }}
{{- if or (eq .Values.deploymentType "StatefulSet") (eq .Values.deploymentType "Deployment") }}
{{- printf "%s-conf-%s" $baseName .Values.md5 | replace "_" "-" | trunc 43 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-conf-%s" $baseName .Values.deploymentType | replace "_" "-" | trunc 43 | trimSuffix "-" | lower }}
{{- end }}
{{- else }}
{{- printf "%s-conf-%s" $baseName .Values.deploymentType | replace "_" "-" | trunc 43 | trimSuffix "-" | lower }}
{{- end }}
{{- end }}


{{/*
Security Context for the deployment
*/}}
{{- define "sitermdebugger.SecurityContext" -}}
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
  {{- fail "Error: 'DaemonSet' deployment type cannot be used when 'logstorage.enabled' is true. Please disable logstorage or change deploymentType to 'StatefulSet' or 'Deployment'." }}
{{- end }}
{{- end }}