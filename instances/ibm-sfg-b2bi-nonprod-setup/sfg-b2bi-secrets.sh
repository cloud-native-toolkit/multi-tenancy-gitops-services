#!/usr/bin/env bash
NS="b2bi-nonprod"
# Set variables
if [[ -z ${B2B_DB_SECRET} ]]; then
  echo "Please provide environment variable B2B_DB_SECRET"
  exit 1
fi

if [[ -z ${JMS_PASSWORD} ]]; then
  echo "Please provide environment variable JMS_PASSWORD"
  exit 1
fi
if [[ -z ${JMS_KEYSTORE_PASSWORD} ]]; then
  echo "Please provide environment variable JMS_KEYSTORE_PASSWORD"
  exit 1
fi
if [[ -z ${JMS_TRUSTSTORE_PASSWORD} ]]; then
  echo "Please provide environment variable JMS_TRUSTSTORE_PASSWORD"
  exit 1
fi

if [[ -z ${B2B_SYSTEM_PASSPHRASE_SECRET} ]]; then
  echo "Please provide environment variable B2B_SYSTEM_PASSPHRASE-SECRET"
  exit 1
fi

B2B_SYSTEM_PASSPHRASE_SECRET=${B2B_SYSTEM_PASSPHRASE_SECRET}

B2B_DB_SECRET=${B2B_DB_SECRET}

JMS_PASSWORD=${JMS_PASSWORD}
JMS_KEYSTORE_PASSWORD=${JMS_KEYSTORE_PASSWORD}
JMS_TRUSTSTORE_PASSWORD=${JMS_TRUSTSTORE_PASSWORD}

SEALED_SECRET_NAMESPACE=${SEALED_SECRET_NAMESPACE:-sealed-secrets}
SEALED_SECRET_CONTOLLER_NAME=${SEALED_SECRET_CONTOLLER_NAME:-sealed-secrets}

### DB2
echo "Setting DB2 access secret"
# Create Kubernetes Secret yaml
oc create secret generic b2b-db-secret --type=Opaque \
--from-literal=DB_USER=db2inst1 \
--from-literal=DB_PASSWORD=${B2B_DB_SECRET} \
--dry-run=client -o yaml > delete-b2b-db-secret-secret.yaml

# Encrypt the secret using kubeseal and private key from the cluster
kubeseal -n ${NS} --controller-name=${SEALED_SECRET_CONTOLLER_NAME} --controller-namespace=${SEALED_SECRET_NAMESPACE} -o yaml < delete-b2b-db-secret-secret.yaml > b2b-db-secret-secret.yaml

# NOTE, do not check delete-b2b-db-secret-secret.yaml into git!
rm delete-b2b-db-secret-secret.yaml

### JMS
echo "Setting JMS access secret"
# Create Kubernetes Secret yaml
oc create secret generic b2b-jms-secret --type=Opaque \
--from-literal=JMS_USERNAME=app \
--from-literal=JMS_PASSWORD=${JMS_PASSWORD} \
--from-literal=JMS_KEYSTORE_PASSWORD=${JMS_KEYSTORE_PASSWORD} \
--from-literal=JMS_TRUSTSTORE_PASSWORD=${JMS_TRUSTSTORE_PASSWORD} \
--dry-run=client -o yaml > delete-b2b-jms-secret-secret.yaml

# Encrypt the secret using kubeseal and private key from the cluster
kubeseal -n ${NS} --controller-name=${SEALED_SECRET_CONTOLLER_NAME} --controller-namespace=${SEALED_SECRET_NAMESPACE} -o yaml < delete-b2b-jms-secret-secret.yaml > b2b-jms-secret-secret.yaml

# NOTE, do not check delete-b2b-jms-secret-secret.yaml into git!
rm delete-b2b-jms-secret-secret.yaml

### B2BI system passphrase
echo "Setting Sterling login password"
# Create Kubernetes Secret yaml
oc create secret generic b2b-system-passphrase-secret --type=Opaque \
--from-literal=SYSTEM_PASSPHRASE=${B2B_SYSTEM_PASSPHRASE_SECRET} \
--dry-run=client -o yaml > delete-b2b-system-passphrase-secret.yaml

# Encrypt the secret using kubeseal and private key from the cluster
kubeseal -n ${NS} --controller-name=${SEALED_SECRET_CONTOLLER_NAME} --controller-namespace=${SEALED_SECRET_NAMESPACE} -o yaml < delete-b2b-system-passphrase-secret.yaml > b2b-system-passphrase-secret.yaml

# NOTE, do not check delete-b2b-system-passphrase-secret.yaml into git!
rm delete-b2b-system-passphrase-secret.yaml
