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
{{- printf "sdnsense/siterm-fe:%s" .Values.image.image }}
{{- else }}
{{- printf "sdnsense/siterm-fe:dev" }}
{{- end }}
{{- else }}
{{- printf "sdnsense/siterm-fe:dev" }}
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
Create a default deployment/statefulset app name used in matching pods/deployments.
We truncate at 43 chars because some Kubernetes name fields are limited to this (by the DNS naming spec) (e.g. max is 63, we leave 20chars).
*/}}
{{- define "sitefe.name" -}}
{{- if .Values.md5 }}
{{- printf "%s-%s-%s" .Chart.Name .Values.sitename .Values.md5 | replace "_" "-" | trunc 43 | trimSuffix "-" | lower }}
{{- else }}
{{- printf "%s-conf-%s" .Chart.Name .Values.sitename | replace "_" "-" | trunc 43 | trimSuffix "-" | lower }}
{{- end }}
{{- end }}

{{/*
Create a default truncname, mainly for pvc, conf, cert
We truncate at 53 chars because there are few addons added, like conf-, cert-, pvc-, pvc-log
*/}}
{{- define "sitefe.truncname" -}}
{{- if .Values.md5 }}
{{- printf "%s-%s-%s" .Chart.Name .Values.sitename .Values.md5 | replace "_" "-" | trunc 53 | trimSuffix "-" | lower }}
{{- else }}
{{- printf "%s-conf-%s" .Chart.Name .Values.sitename | replace "_" "-" | trunc 53 | trimSuffix "-" | lower }}
{{- end }}
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

{{/*
Evaluate whether logstorage.enabled is true
*/}}
{{- define "sitefe.logstorageEnabled" -}}
{{- $enabled := false }}
{{- if and (not (kindIs "invalid" .Values.logstorage)) (kindIs "map" .Values.logstorage) }}
  {{- if hasKey .Values.logstorage "enabled" }}
    {{- $enabled = .Values.logstorage.enabled }}
  {{- end }}
{{- end }}
{{- ternary "true" "false" $enabled }}
{{- end }}

{{/*
Evaluate whether storage.enabled is true
*/}}
{{- define "sitefe.storageEnabled" -}}
{{- $enabled := false }}
{{- if and (not (kindIs "invalid" .Values.storage)) (kindIs "map" .Values.storage) }}
  {{- if hasKey .Values.storage "enabled" }}
    {{- $enabled = .Values.storage.enabled }}
  {{- end }}
{{- end }}
{{- ternary "true" "false" $enabled }}
{{- end }}
