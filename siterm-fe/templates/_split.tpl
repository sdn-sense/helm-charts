{{/*
Split mode helpers: one Deployment per SiteRM component, sharing nothing but the database.
*/}}

{{/*
Base name of split Deployments and Jobs (at most 32 chars, unique per site). Pod hostnames are cut at 63 chars, which
for longer names drops the replica suffix and gives replicas the same lease/instance identity.
*/}}
{{- define "sitefe.splitbase" -}}
{{- $name := include "sitefe.name" . -}}
{{- printf "%s-%s" ($name | trunc 23 | trimSuffix "-") ($name | sha256sum | trunc 8) -}}
{{- end }}

{{/*
Volume mounts of a component container. Call with (dict "root" $ "component" $component).
*/}}
{{- define "sitefe.splitMounts" -}}
{{- $root := .root -}}
- mountPath: /etc/siterm.yaml
  name: conf-{{ include "sitefe.truncname" $root }}
  subPath: sense-siterm-fe.yaml
{{- if $root.Values.manualConfig.enabled }}
- mountPath: /etc/siterm-config/main.yaml
  name: conf-{{ include "sitefe.truncname" $root }}
  subPath: manual-main.yaml
- mountPath: /etc/siterm-config/auth.yaml
  name: conf-{{ include "sitefe.truncname" $root }}
  subPath: manual-auth.yaml
{{- if $root.Values.manualConfig.auth_re }}
- mountPath: /etc/siterm-config/auth-re.yaml
  name: conf-{{ include "sitefe.truncname" $root }}
  subPath: manual-auth-re.yaml
{{- end }}
{{- end }}
- mountPath: /etc/environment
  name: secret-{{ include "sitefe.truncname" $root }}
  readOnly: true
  subPath: environment.conf
- mountPath: /etc/ansible-conf.yaml
  name: secret-{{ include "sitefe.truncname" $root }}
  readOnly: true
  subPath: ansible-conf.yaml
- mountPath: /etc/secret-mount
  name: cert-{{ include "sitefe.truncname" $root }}
  readOnly: true
{{- if $root.Values.sshkeys }}
- name: sshvol-{{ include "sitefe.truncname" $root }}
  mountPath: /opt/siterm/config/ssh-keys/
  readOnly: true
{{- end }}
{{- if eq .component "frontend" }}
- name: jwt-{{ include "sitefe.truncname" $root }}
  mountPath: /etc/siterm-jwt
  readOnly: true
{{- end }}
{{- end }}

{{/*
Volumes of a component pod. Call with (dict "root" $ "component" $component).
*/}}
{{- define "sitefe.splitVolumes" -}}
{{- $root := .root -}}
- configMap:
    defaultMode: 420
    items:
    - key: sense-siterm-fe
      path: sense-siterm-fe.yaml
    {{- if $root.Values.manualConfig.enabled }}
    - key: manual-main
      path: manual-main.yaml
    - key: manual-auth
      path: manual-auth.yaml
    {{- if $root.Values.manualConfig.auth_re }}
    - key: manual-auth-re
      path: manual-auth-re.yaml
    {{- end }}
    {{- end }}
    name: conf-{{ include "sitefe.truncname" $root }}
  name: conf-{{ include "sitefe.truncname" $root }}
- name: secret-{{ include "sitefe.truncname" $root }}
  secret:
    defaultMode: 420
    items:
    - key: fe-environment
      path: environment.conf
    - key: ansible-conf
      path: ansible-conf.yaml
    secretName: secret-{{ include "sitefe.truncname" $root }}
- name: cert-{{ include "sitefe.truncname" $root }}
  secret:
    secretName: cert-{{ include "sitefe.truncname" $root }}
{{- if $root.Values.sshkeys }}
- name: sshvol-{{ include "sitefe.truncname" $root }}
  secret:
    secretName: sshkey-{{ include "sitefe.truncname" $root }}
    defaultMode: 0600
    items:
    {{- range $key, $path := $root.Values.sshkeys }}
    - key: {{ $key }}
      path: {{ $key }}
    {{- end }}
{{- end }}
{{- if eq .component "frontend" }}
- name: jwt-{{ include "sitefe.truncname" $root }}
  secret:
    secretName: jwt-{{ include "sitefe.truncname" $root }}
    defaultMode: 0400
{{- end }}
{{- end }}

{{/*
Pod scheduling settings shared by all split-mode pods.
*/}}
{{- define "sitefe.splitScheduling" -}}
{{- if and .Values.tolerations (not (empty .Values.tolerations)) }}
tolerations:
  {{ .Values.tolerations | toYaml | indent 2 | trim }}
{{- end }}
{{- if and .Values.affinity (not (empty .Values.affinity)) }}
affinity:
  {{ .Values.affinity | toYaml | indent 2 | trim }}
{{- end }}
{{- if and .Values.nodeSelector (not (empty .Values.nodeSelector)) }}
nodeSelector:
  {{ .Values.nodeSelector | toYaml | indent 2 | trim }}
{{- end }}
{{- if .Values.priorityClassName }}
priorityClassName: {{ .Values.priorityClassName }}
{{- end }}
{{- end }}
