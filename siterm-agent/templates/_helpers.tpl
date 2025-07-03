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
{{- if .Values.lldpd.path }}
{{- .Values.lldpd.path }}
{{- else }}
/var/run/lldpd.sock
{{- end }}
{{- end }}

{{/*
Set iproute/rt_tables enabled flag. Default True
*/}}
{{- define "sitermagent.rttablesEnabled" -}}
{{- $enabled := true }}
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
{{- if .Values.rttables.path }}
{{- .Values.rttables.path }}
{{- else }}
/etc/iproute2/rt_tables
{{- end }}
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