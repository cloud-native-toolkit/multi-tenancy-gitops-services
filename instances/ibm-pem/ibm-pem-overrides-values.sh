#!/usr/bin/env bash
# Set enviroment variables
# Declaring IBM SFG PROD

NS="pem"
PEM_NS=${NS}
B2BI_PROD=${B2BI_PROD:-"b2bi-prod"}
B2BI_NONPROD=${B2BI_NONPROD:-"b2bi-nonprod"}
PEM_VERSION=${PEM_VERSION:-"6.2.0.2"}
RWX_STORAGECLASS=${RWX_STORAGECLASS:-"ibmc-file-gold"}
CUSTOMER_ID=${CUSTOMER_ID:-"ibm@ibm.com"}
PEM_SECRET=${PEM_SECRET:-"ibm-pem-secret"}

# Create Kubernetes yaml
( echo "cat <<EOF" ; cat ibm-pem-overrides-values.yaml_template ;) | \
PEM_NS=${PEM_NS} \
B2BI_PROD=${B2BI_PROD} \
B2BI_NONPROD=${B2BI_NONPROD} \
CUSTOMER_ID=${CUSTOMER_ID} \
PEM_VERSION=${PEM_VERSION} \
PEM_SECRET=${PEM_SECRET} \
RWX_STORAGECLASS=${RWX_STORAGECLASS} \
sh > values.yaml
