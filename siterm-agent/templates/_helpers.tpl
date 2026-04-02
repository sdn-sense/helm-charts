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
{{- printf "sdnsense/siterm-agent:%s" .Values.image.image }}
{{- else }}
{{- printf "sdnsense/siterm-agent:latest" }}
{{- end }}
{{- else }}
{{- printf "sdnsense/siterm-agent:latest" }}
{{- end }}
{{- end }}

{{/*
Define Deployment image for debugger
*/}}
{{- define "deploymentimagedebug" -}}
{{- if .Values.image }}
{{- if .Values.image.image }}
{{- printf "sdnsense/siterm-debugger:%s" .Values.image.image }}
{{- else }}
{{- printf "sdnsense/siterm-debugger:latest" }}
{{- end }}
{{- else }}
{{- printf "sdnsense/siterm-debugger:latest" }}
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
Define Deployment OS release
*/}}
{{- define "deploymentosrelease" -}}
{{- if .Values.osrelease }}
{{- printf "%s" .Values.osrelease }}
{{- else }}
{{- printf "el10"}}
{{- end }}
{{- end }}

{{/*
Define CPU and Memory Limits/Requests for Agent
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
Define CPU and Memory Limits/Requests for Debugger
*/}}
{{- define "cpulimitdebugger" -}}
{{- if .Values.cpuLimitdebugger }}
{{- toString .Values.cpuLimitdebugger }}
{{- else }}
{{- printf "16"}}
{{- end }}
{{- end }}

{{- define "cpuRequestdebugger" -}}
{{- if .Values.cpuRequestdebugger }}
{{- toString .Values.cpuRequestdebugger }}
{{- else }}
{{- printf "600m"}}
{{- end }}
{{- end }}

{{- define "memorylimitdebugger" -}}
{{- if .Values.memoryLimitdebugger }}
{{- toString .Values.memoryLimitdebugger }}
{{- else }}
{{- printf "32Gi"}}
{{- end }}
{{- end }}

{{- define "memoryRequestdebugger" -}}
{{- if .Values.memoryRequestdebugger }}
{{- toString .Values.memoryRequestdebugger }}
{{- else }}
{{- printf "1Gi"}}
{{- end }}
{{- end }}

{{/*
Evaluate whether deploydebugger is enabled, default true.
*/}}
{{- define "sitermagent.deploydebuggerEnabled" -}}
{{- $enabled := true }} {{/* default true */}}
{{- if not (kindIs "invalid" .Values.deploydebugger) }}
  {{- $enabled = .Values.deploydebugger }}
{{- end }}
{{- ternary "true" "false" $enabled }}
{{- end }}

{{/*
Expand the name of the chart.
*/}}

{{/*
Create a default deployment/statefulset/daemonset app name used in matching pods/deployments.
We truncate at 43 chars because some Kubernetes name fields are limited to this (by the DNS naming spec) (e.g. max is 63, we leave 20chars).
*/}}
{{- define "sitermagent.name" -}}
{{- if .Values.md5 }}
{{- if or (eq .Values.deploymentType "StatefulSet") (eq .Values.deploymentType "Deployment") }}
{{- printf "%s-conf-%s" .Chart.Name .Values.md5 | replace "_" "-" | trunc 43 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-conf-%s" .Chart.Name .Values.deploymentType | replace "_" "-" | trunc 43 | trimSuffix "-" | lower }}
{{- end }}
{{- else }}
{{- printf "%s-conf-%s" .Chart.Name .Values.deploymentType | replace "_" "-" | trunc 43 | trimSuffix "-" | lower }}
{{- end }}
{{- end }}

{{/*
Create a default truncname, mainly for pvc, conf, cert
We truncate at 53 chars because there are few addons added, like conf-, cert-, pvc-, pvc-log
*/}}
{{- define "sitermagent.truncname" -}}
{{- if .Values.md5 }}
{{- if or (eq .Values.deploymentType "StatefulSet") (eq .Values.deploymentType "Deployment") }}
{{- printf "%s-conf-%s" .Chart.Name .Values.md5 | replace "_" "-" | trunc 53 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-conf-%s" .Chart.Name .Values.deploymentType | replace "_" "-" | trunc 53 | trimSuffix "-" | lower }}
{{- end }}
{{- else }}
{{- printf "%s-conf-%s" .Chart.Name .Values.deploymentType | replace "_" "-" | trunc 53 | trimSuffix "-" | lower }}
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
Set lldpd daemon enabled flag. Default True
*/}}
{{- define "sitermagent.lldpEnabled" -}}
{{- $enabled := true }}
{{- if and (not (kindIs "invalid" .Values.lldpd)) (kindIs "map" .Values.lldpd) }}
  {{- if hasKey .Values.lldpd "enabled" }}
    {{- $enabled = .Values.lldpd.enabled }}
  {{- end }}
{{- end }}
{{- ternary "true" "false" $enabled }}
{{- end }}

{{/*}}
Set default lldpd daemon path, /var/run/lldpd.sock, allow to override
*/}}
{{- define "sitermagent.lldpPath" -}}
{{- $lldpd := .Values.lldpd | default dict -}}
{{- $lldpd.path | default "/var/run/lldpd.sock" -}}
{{- end }}

{{/*
Set iproute/rt_tables enabled flag. Default False
*/}}
{{- define "sitermagent.rttablesEnabled" -}}
{{- $enabled := false }}
{{- if and (not (kindIs "invalid" .Values.rttables)) (kindIs "map" .Values.rttables) }}
  {{- if hasKey .Values.rttables "enabled" }}
    {{- $enabled = .Values.rttables.enabled }}
  {{- end }}
{{- end }}
{{- ternary "true" "false" $enabled }}
{{- end }}

{{/*
Set default iproute/rt_tables path, /etc/iproute2/rt_tables, allow to override
*/}}
{{- define "sitermagent.rttablesPath" -}}
{{- $rttables := .Values.rttables | default dict -}}
{{- $rttables.path | default "/etc/iproute2/rt_tables" -}}
{{- end }}
{{/*
Validation check: DaemonSet cannot be used if logstorage.enabled is true
*/}}
{{- define "sitermagent.validateDeploymentType" -}}
{{- $logEnabled := (include "sitermagent.logstorageEnabled" .) | trim | eq "true" }}
{{- if and (eq .Values.deploymentType "DaemonSet") $logEnabled }}
  {{- fail "Error: 'DaemonSet' deployment type cannot be used when 'logstorage.enabled' is true. Please disable logstorage or change deploymentType to 'StatefulSet' or 'Deployment'." }}
{{- end }}
{{- end }}