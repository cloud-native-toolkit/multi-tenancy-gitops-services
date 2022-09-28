#!/usr/bin/env bash

NS="ssp"
# Set variables
if [[ -z ${CM_SYS_PASS} ]]; then
  echo "Please provide environment variable CM_SYS_PASS"
  exit 1
fi

if [[ -z ${CM_ADMIN_PASSWORD} ]]; then
  echo "Please provide environment variable CM_ADMIN_PASSWORD"
  exit 1
fi
if [[ -z ${CM_CERTSTORE_PASSWORD} ]]; then
  echo "Please provide environment variable CM_CERTSTORE_PASSWORD"
  exit 1
fi
if [[ -z ${CM_CERTENCRYPT_PASSWORD} ]]; then
  echo "Please provide environment variable JMS_TRUSTSTORE_PASSWORD"
  exit 1
fi

if [[ -z ${CM_CUSTOMCERT_PASSWORD} ]]; then
  echo "Please provide environment variable CM_CUSTOMCERT_PASSWORD"
  exit 1
fi

if [[ -z ${ENGINE_SYS_PASS} ]]; then
  echo "Please provide environment variable ENGINE_SYS_PASS"
  exit 1
fi

if [[ -z ${ENGINE_CERTSTORE_PASSWORD} ]]; then
  echo "Please provide environment variable ENGINE_CERTSTORE_PASSWORD"
  exit 1
fi

if [[ -z ${ENGINE_CERTENCRYPT_PASSWORD} ]]; then
  echo "Please provide environment variable ENGINE_CERTENCRYPT_PASSWORD"
  exit 1
fi

if [[ -z ${ENGINE_CUSTOMCERT_PASSWORD} ]]; then
  echo "Please provide environment variable ENGINE_CUSTOMCERT_PASSWORD"
  exit 1
fi

if [[ -z ${RWX_STORAGECLASS}  ]]; then
  echo "Please provide environment variable RWX_STORAGECLASS"
  exit 1
fi

SEALED_SECRET_NAMESPACE=${SEALED_SECRET_NAMESPACE:-sealed-secrets}
SEALED_SECRET_CONTROLLER_NAME=${SEALED_SECRET_CONTOLLER_NAME:-sealed-secrets}

### Configuration Manager
printf "Creating Configuration Manager Secret \n"

# Create Kubernetes Secret yaml
oc create secret generic ibm-ssp-cm-secret --type=Opaque \
--from-literal=sysPassphrase="${CM_SYS_PASS}" \
--from-literal=adminPassword="${CM_ADMIN_PASSWORD}" \
--from-literal=keyCertStorePassphrase="${CM_CERTSTORE_PASSWORD}" \
--from-literal=keyCertEncryptPassphrase="${CM_CERTENCRYPT_PASSWORD}" \
--from-literal=customKeyCertPassphrase="${CM_CUSTOMCERT_PASSWORD}" \
--dry-run=client -o yaml > delete-ssp-cm-secret.yaml

# Encrypt the secret using kubeseal and private key from the cluster
kubeseal -n ${NS} --controller-name="${SEALED_SECRET_CONTROLLER_NAME}" --controller-namespace="${SEALED_SECRET_NAMESPACE}" -o yaml < delete-ssp-cm-secret.yaml

# NOTE, do not check delete-ssp-cm-secret.yaml into git!
rm delete-ssp-cm-secret.yaml
### Engine
printf "Creating Engine secret \n"

# Create Kubernetes Secret yaml
oc create secret generic ibm-ssp-engine-secret --type=Opaque \
--from-literal=sysPassphrase="${ENGINE_SYS_PASS}" \
--from-literal=keyCertStorePassphrase="${ENGINE_CERTSTORE_PASSWORD}" \
--from-literal=keyCertEncryptPassphrase="${ENGINE_CERTENCRYPT_PASSWORD}" \
--from-literal=customKeyCertPassphrase="${ENGINE_CUSTOMCERT_PASSWORD}" \
--dry-run=client -o yaml > delete-ibm-ssp-engine-secret.yaml

# Encrypt the secret using kubeseal and private key from the cluster
kubeseal -n ${NS} --controller-name="${SEALED_SECRET_CONTROLLER_NAME}" --controller-namespace="${SEALED_SECRET_NAMESPACE}" -o yaml < delete-ibm-ssp-engine-secret.yaml

# NOTE, do not check delete-ibm-ssp-engine-secret.yaml into git!
rm delete-ibm-ssp-engine-secret.yaml

printf "Creating Service Accounts \n"

oc create sa ssp-cm-serviceaccount -n "${NS}"
oc create sa ssp-engine-serviceaccount -n "${NS}"
oc create sa ssp-argocd-hook-job -n "${NS}"

( echo "cat <<EOF" ; cat ssp-cm-pvc.yaml_template ;) | \
sh > ssp-cm-pvc.yaml

( echo "cat <<EOF" ; cat ssp-engine-pvc.yaml_template ;) | \
sh > ssp-engine-pvc.yaml