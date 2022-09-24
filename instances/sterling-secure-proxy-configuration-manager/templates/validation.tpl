{{/*
A function to validate if passed parameter is a valid integer
*/}}
{{- define "integerValidation" -}}
{{- $type := kindOf . -}}
{{- if or (eq $type "float64") (eq $type "int") -}}
    {{- $isIntegerPositive := include "isIntegerPositive" . -}}
    {{- if eq $isIntegerPositive "true" -}}
    	true
    {{- else -}}
    	false
    {{- end -}}	
{{- else -}}
    false
{{- end -}}
{{- end -}}

{{/*
A function to validate if passed integer is non negative
*/}}
{{- define "isIntegerPositive" -}}
{{- $inputInt := int64 . -}}
{{- if gt $inputInt -1 -}}
    true
{{- else -}}
    false
{{- end -}}
{{- end -}}

{{/*
A function to validate if passed parameter is a valid string
*/}}
{{- define "stringValidation" -}}
{{- $type := kindOf . -}}
{{- if or (eq $type "string") (eq $type "String") -}}
    true
{{- else -}}
    false
{{- end -}}
{{- end -}}

{{/*
A function to check for mandatory arguments
*/}}
{{- define "mandatoryArgumentsCheck" -}}
{{- if . -}}
    true
{{- else -}}
    false
{{- end -}}
{{- end -}}

{{/*
A function to check for port range
*/}}
{{- define "portRangeValidation" -}}
{{- $portNo := int64 . -}}
{{- if and (gt $portNo 0) (lt $portNo 65536) -}}
    true
{{- else -}}
    false
{{- end -}}
{{- end -}}

{{/*
A function to check if port is valid
*/}}
{{- define "isPortValid" -}}
{{- $result := include "integerValidation" . -}}
{{- if eq $result "true" -}}
	{{- $isPortValid := include "portRangeValidation" . -}}
	{{- if eq $isPortValid "true" -}}
	true
	{{- else -}}
	false
	{{- end -}}
{{- else -}}
	false
{{- end -}}
{{- end -}}


{{/*
A function to check for validity of service ports
*/}}
{{- define "servicePortsCheck" -}}
{{- $result := include "isPortValid" .port -}}
{{- if eq $result "false" -}}
{{- fail "Provide a valid value for ports in service" -}}
{{- end -}}

{{- $result := include "isPortValid" .targetPort -}}
{{- if eq $result "false" -}}
{{- fail "Provide a valid value for targetPort in service" -}}
{{- end -}}

{{- $result := include "isPortValid" .portRange -}}
{{- if eq $result "false" -}}
{{- fail "Provide a valid value for portRange in service" -}}
{{- end -}}
{{- end -}}

{{/*
A function to validate an email address
*/}}
{{- define "emailValidator" -}}
{{- $emailRegex := "^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$" -}}
{{- $isValid := regexMatch $emailRegex . -}}
{{- if eq $isValid true -}}
	true
{{- else -}}
	false	
{{- end -}}
{{- end -}}

{{/*
A function to validate size
*/}}
{{- define "size" -}}
{{- $sizeRegex := "^[0-9][KMG][i]$" -}}
{{- $isValid := regexMatch $sizeRegex . -}}
{{- if eq $isValid true -}}
        true
{{- else -}}
        false
{{- end -}}
{{- end -}}

{{/*
Main function to test the input validations
*/}}

{{- define "validateInput" -}}

{{- $isValid := toString .Values.license -}}
{{- if ne $isValid "true" -}}
{{- fail "Configuration Error: Please provide a valid value for field Values.license. Set this field as true to accept the license agreement for this chart." -}}
{{- end -}}

{{- $typeStr :=  .Values.licenseType | toString | lower -}}
{{- if not ( or (eq $typeStr "prod") (eq $typeStr "non-prod")) -}}
{{- fail "Configuration Error: Please provide a valid value for parameter licenseType. Value can be either prod or non-prod." -}}
{{- end -}}

{{- $result := include "mandatoryArgumentsCheck" .Values.image.repository -}}
{{- if eq $result "false" -}}
{{- fail "Configuration Missing: .Values.image.repository cannot be empty. Please provide a valid repository name along with image name" -}}
{{- end -}}

{{- $isValid := toString .Values.image.digest.enabled -}}
{{- if eq $isValid "true" -}}
{{- $result := include "mandatoryArgumentsCheck" .Values.image.digest.value -}}
{{- if eq $result "false" -}}
{{- fail "Configuration Missing: .Values.image.digest.value cannot be empty. Please provide a valid image digest value." -}}
{{- end -}}
{{- end -}}

{{- if eq $isValid "false" -}}
{{- $result := include "mandatoryArgumentsCheck" .Values.image.tag -}}
{{- if eq $result "false" -}}
{{- fail "Configuration Missing: .Values.image.tag cannot be empty. Please provide a valid image tag." -}}
{{- end -}}
{{- end -}}

{{- $result := include "mandatoryArgumentsCheck" .Values.image.pullPolicy -}}
{{- if eq $result "false" -}}
{{- fail "Configuration Missing: .Values.pullPolicy cannot be empty. Please provide a valid pull policy for image." -}}
{{- end -}}

{{- if or (.Release.IsInstall) (.Values.customCertificate.customCertEnabled) }}
{{- $result := include "mandatoryArgumentsCheck" .Values.secret.secretName -}}
{{- if eq $result "false" -}}
{{- fail "Configuration Missing: Please provide valid value for Values.secret.secretName" -}}
{{- end -}}
{{- end -}}

{{- $result := include "mandatoryArgumentsCheck" .Values.cmArgs.keyCertAliasName -}}
{{- if eq $result "false" -}}
{{- fail "Configuration Missing: Please provide valid value for Values.cmArgs.keyCertAliasName" -}}
{{- end -}}

{{- $result := include "mandatoryArgumentsCheck" .Values.service.cm.containerPort -}}
{{- if eq $result "false" -}}
{{- fail "Configuration Missing: Please provide valid value for Values.service.cm.containerPort" -}}
{{- end -}}

{{- $result := include "mandatoryArgumentsCheck" .Values.service.jetty.containerPort -}}
{{- if eq $result "false" -}}
{{- fail "Configuration Missing: Please provide valid value for Values.service.jetty.containerPort" -}}
{{- end -}}

{{- if .Values.customCertificate.customCertEnabled }}
{{- $result := include "mandatoryArgumentsCheck" .Values.customCertificate.commonCertFile -}}
{{- if eq $result "false" -}}
{{- fail "Configuration Missing: Please provide valid value for Values.customCertificate.commonCertFile" -}}
{{- end -}}
{{- $result := include "mandatoryArgumentsCheck" .Values.customCertificate.commonCertAlias -}}
{{- if eq $result "false" -}}
{{- fail "Configuration Missing: Please provide valid value for Values.customCertificate.commonCertAlias" -}}
{{- end -}}
{{- $result := include "mandatoryArgumentsCheck" .Values.customCertificate.commonKeyCertFile -}}
{{- if eq $result "false" -}}
{{- fail "Configuration Missing: Please provide valid value for Values.customCertificate.commonKeyCertFile" -}}
{{- end -}}
{{- end -}}

{{- end -}}

{{ include "validateInput" .  }}