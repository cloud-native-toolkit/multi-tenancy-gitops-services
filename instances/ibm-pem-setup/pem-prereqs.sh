#!/usr/bin/env bash

NS="pem"

# Set variables
if [[ -z ${PEM_DB_PASSWORD} ]]; then
  echo "Please provide environment variable PEM_DB_PASSWORD"
  exit 1
fi

if [[ -z ${PEM_PASSWORD} ]]; then
  echo "Please provide environment variable PEM_PASSWORD"
  exit 1
fi

if [[ -z ${SERVER_KEYSTORE_PASSWORD} ]]; then
  echo "Please provide environment variable SERVER_KEYSTORE_PASSWORD"
  exit 1
fi

if [[ -z ${B2BI_PROD_PASSWORD} ]]; then
  echo "Please provide environment variable B2BI_PROD_PASSWORD"
  exit 1
fi
if [[ -z ${B2BI_PROD_DB_PASSWORD} ]]; then
  echo "Please provide environment variable B2BI_PROD_DB_PASSWORD"
  exit 1
fi
if [[ -z ${B2BI_NONPROD_PASSWORD} ]]; then
  echo "Please provide environment variable B2BI_PROD_PASSWORD"
  exit 1
fi
if [[ -z ${B2BI_NONPROD_DB_PASSWORD} ]]; then
  echo "Please provide environment variable B2BI_PROD_DB_PASSWORD"
  exit 1
fi

RWX_STORAGECLASS=${RWX_STORAGECLASS:-"managed-nfs-storage"}

SEALED_SECRET_NAMESPACE=${SEALED_SECRET_NAMESPACE:-sealed-secrets}
SEALED_SECRET_CONTOLLER_NAME=${SEALED_SECRET_CONTOLLER_NAME:-sealed-secrets}

# Create Kubernetes Secret yaml
echo "Creating ibm-pem-secret"

oc create secret generic ibm-pem-secret --type=Opaque \
  --from-literal=PROXY_PASSWORD="" \
  --from-literal=DB_PASSWORD=${PEM_DB_PASSWORD} \
  --from-literal=DB_SSLTRUSTSTORE_PASSWORD="" \
  --from-literal=TESTMODE_DB_PASSWORD=${PEM_DB_PASSWORD} \
  --from-literal=PEM_SERVERS_KEYSTORE_PASSWORD=${SERVER_KEYSTORE_PASSWORD} \
  --from-literal=GATEWAY_SERVERS_KEYSTORE_PASSWORD=${SERVER_KEYSTORE_PASSWORD} \
  --from-literal=PP_SERVERS_KEYSTORE_PASSWORD=${SERVER_KEYSTORE_PASSWORD} \
  --from-literal=PR_SERVERS_KEYSTORE_PASSWORD=${SERVER_KEYSTORE_PASSWORD} \
  --from-literal=passphrase.txt=${PEM_PASSWORD} \
  --from-literal=WMQ_SERVERS_PASSWORD="" \
  --from-literal=SSO_KEYSTOREPASSWORD="" \
  --from-literal=SSO_TRUSTSTOREPASSWORD="" \
  --from-literal=TESTDB_SSLTRUSTSTORE_PASSWORD="" \
  --from-literal=PURGE_TARGET_DB_PASSWORD="" \
  --from-literal=PURGE_TARGET_DB_TRUSTSTORE_PASSWORD="" \
  --dry-run=client -o yaml > delete-ibm-pem-secret.yaml

# Encrypt the secret using kubeseal and private key from the cluster
kubeseal -n ${NS} --controller-name=${SEALED_SECRET_CONTOLLER_NAME} --controller-namespace=${SEALED_SECRET_NAMESPACE} -o yaml < delete-ibm-pem-secret.yaml > ibm-pem-secret.yaml
rm delete-ibm-pem-secret.yaml

echo "Creating ibm-pem-cm-secret-prod"
oc create secret generic ibm-pem-cm-secret-prod --type=Opaque \
  --from-literal=DB_PASS=${B2BI_PROD_DB_PASSWORD} \
  --from-literal=APPLICATION_PASSPHRASE=${B2BI_PROD_PASSWORD} \
  --from-literal=SERVER_KEYSTORE_PASSWORD=${SERVER_KEYSTORE_PASSWORD} \
  --from-literal=DB_TRUSTSTORE_PASSWORD="" \
  --from-literal=SMTP_PASSWORD="" \
  --from-literal=API_PASSWORD="" \
  --from-literal=STERLING_SYSTEM_PASSPHRASE=${B2BI_PROD_PASSWORD} \
  --from-literal=STERLING_B2BAPI_PASSWORD=${B2BI_PROD_PASSWORD} \
  --from-literal=STERLING_SFGAPI_PASSWORD=${B2BI_PROD_PASSWORD} \
  --from-literal=SSP_PASSWORD="" \
  --from-literal=SAML_KEY_PASSWORD="" \
  --from-literal=SAML_KEYSTORE_PASSWORD="" \
  --from-literal=PEM_DB_PASSWORD=${PEM_DB_PASSWORD}  \
  --from-literal=PEM_API_PASSWORD=${PEM_PASSWORD}  \
  --from-literal=PGP_PASSPHRASE="" \
  --from-literal=SEAS_TRUSTSTORE_PASSWORD="" \
  --from-literal=SEAS_KEYSTORE_PASSWORD="" \
  --dry-run=client -o yaml > delete-ibm-pem-cm-secret-prod.yaml

kubeseal -n ${NS} --controller-name=${SEALED_SECRET_CONTOLLER_NAME} --controller-namespace=${SEALED_SECRET_NAMESPACE} -o yaml < delete-ibm-pem-cm-secret-prod.yaml > ibm-pem-cm-secret-prod.yaml
rm delete-ibm-pem-cm-secret-prod.yaml


echo "Creating ibm-pem-cm-secret-nonprod"
oc create secret generic ibm-pem-cm-secret-nonprod --type=Opaque \
  --from-literal=DB_PASS=${B2BI_NONPROD_DB_PASSWORD} \
  --from-literal=APPLICATION_PASSPHRASE=${B2BI_NONPROD_PASSWORD} \
  --from-literal=SERVER_KEYSTORE_PASSWORD=${SERVER_KEYSTORE_PASSWORD} \
  --from-literal=DB_TRUSTSTORE_PASSWORD="" \
  --from-literal=SMTP_PASSWORD="" \
  --from-literal=API_PASSWORD="" \
  --from-literal=STERLING_SYSTEM_PASSPHRASE=${B2BI_NONPROD_PASSWORD} \
  --from-literal=STERLING_B2BAPI_PASSWORD=${B2BI_NONPROD_PASSWORD} \
  --from-literal=STERLING_SFGAPI_PASSWORD=${B2BI_NONPROD_PASSWORD} \
  --from-literal=SSP_PASSWORD="" \
  --from-literal=SAML_KEY_PASSWORD="" \
  --from-literal=SAML_KEYSTORE_PASSWORD="" \
  --from-literal=PEM_DB_PASSWORD=${PEM_DB_PASSWORD}  \
  --from-literal=PEM_API_PASSWORD=${PEM_PASSWORD}  \
  --from-literal=PGP_PASSPHRASE="" \
  --from-literal=SEAS_TRUSTSTORE_PASSWORD="" \
  --from-literal=SEAS_KEYSTORE_PASSWORD="" \
  --dry-run=client -o yaml > delete-ibm-pem-cm-secret-nonprod.yaml

kubeseal -n ${NS} --controller-name=${SEALED_SECRET_CONTOLLER_NAME} --controller-namespace=${SEALED_SECRET_NAMESPACE} -o yaml < delete-ibm-pem-cm-secret-nonprod.yaml > ibm-pem-cm-secret-nonprod.yaml
rm delete-ibm-pem-cm-secret-nonprod.yaml

echo "Creating ibm-pem.jks certificate"
DOMAIN=$(oc get ingresscontroller -n openshift-ingress-operator   default -o jsonpath='{.status.domain}')
keytool -genkey -keystore ibm-pem.jks -storepass ${SERVER_KEYSTORE_PASSWORD} -alias pem -dname "CN=*.${DOMAIN}" -keypass ${SERVER_KEYSTORE_PASSWORD} -sigalg SHA256withRSA -keyalg RSA

oc create secret generic ibm-pem.jks --type=Opaque --from-file ibm-pem.jks --dry-run=client -o yaml > delete-ibm-pem-jks.yaml
kubeseal -n ${NS} --controller-name=${SEALED_SECRET_CONTOLLER_NAME} --controller-namespace=${SEALED_SECRET_NAMESPACE} -o yaml < delete-ibm-pem-jks.yaml > ibm-pem-jks.yaml
rm ibm-pem.jks
rm delete-ibm-pem-jks.yaml

echo "Populating resource PVC from ${RWX_STORAGECLASS}"

( echo "cat <<EOF" ; cat ibm-pem-resources-pvc.yaml_template ;) | \
RWX_STORAGECLASS=${RWX_STORAGECLASS} \
sh > ibm-pem-resources-pvc.yaml
