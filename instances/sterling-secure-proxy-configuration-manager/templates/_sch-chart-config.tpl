{{- /*
Chart specific config file for SCH (Shared Configurable Helpers)
_sch-chart-config.tpl is a config file for the chart to specify additional
values and/or override values defined in the sch/_config.tpl file.

*/ -}}

{{- /*
"sch.chart.config.values" contains the chart specific values used to override or provide
additional configuration values used by the Shared Configurable Helpers.
*/ -}}
{{- define "ibm-ssp-cm.sch.chart.config.values" -}}
sch:
  chart:
    appName: "ibm-ssp-cm"
    metering:
	{{- if eq (toString .Values.licenseType | lower) "non-prod"  }}
      productName: "IBM Sterling Secure Proxy Non Production Certified Container"
      productID: "e18189cc82074dba85acbe6b764090a7"
    {{- else }}
      productName: "IBM Sterling Secure Proxy Certified Container"
      productID: "9b921dda8dd141bf8869ead1a790d4da"
    {{- end }}
      productVersion: "6.0.3"
      productMetric: "VIRTUAL_PROCESSOR_CORE"
      productChargedContainers: ""
    podSecurityContext:
      runAsNonRoot: true
      supplementalGroups: [ {{ .Values.storageSecurity.supplementalGroupId | default 5555 }} ] 
      fsGroup: 1000
      runAsGroup: 1000
      runAsUser: 1000            
    initContainerSecurityContext:
      privileged: false
      runAsUser: 1000
      readOnlyRootFilesystem: false
      allowPrivilegeEscalation: true
      capabilities:
        drop: [ "ALL" ]
        add: [ "CHOWN", "SETGID", "SETUID", "FOWNER", "DAC_OVERRIDE" ]
    containerSecurityContext:
      privileged: false
      runAsUser: 1000
      readOnlyRootFilesystem: false
      allowPrivilegeEscalation: false
      capabilities:
        drop: [ "ALL" ]
{{- end -}}
