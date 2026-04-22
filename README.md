# DOCUMENTATION: https://sdn-sense.github.io/

SiteRM charts use the Git-backed configuration repository by default. To provide `main.yaml`, `auth.yaml`, and `auth-re.yaml` directly from Helm values, enable the chart `manualConfig` block. The chart will create ConfigMap entries and mount them under `/etc/siterm-config/`; if `manualConfig.enabled` is false or omitted, the existing Git clone/pull mode is used.
