#!/usr/bin/env bash

# Set variables
if [[ -z ${B2B_SYSTEM_PASSPHRASE_SECRET} ]]; then
  echo "Please provide environment variable B2B_SYSTEM_PASSPHRASE-SECRET"
  exit 1
fi

B2B_SYSTEM_PASSPHRASE_SECRET=${B2B_SYSTEM_PASSPHRASE_SECRET}

SEALED_SECRET_NAMESPACE=${SEALED_SECRET_NAMESPACE:-sealed-secrets}
SEALED_SECRET_CONTOLLER_NAME=${SEALED_SECRET_CONTOLLER_NAME:-sealed-secrets}

# Create Kubernetes Secret yaml
oc create secret generic b2b-system-passphrase-secret --type=Opaque \
--from-literal=SYSTEM_PASSPHRASE=${B2B_SYSTEM_PASSPHRASE_SECRET} \
--dry-run=client -o yaml > delete-b2b-system-passphrase-secret.yaml

# Encrypt the secret using kubeseal and private key from the cluster
kubeseal -n tools --controller-name=${SEALED_SECRET_CONTOLLER_NAME} --controller-namespace=${SEALED_SECRET_NAMESPACE} -o yaml < delete-b2b-system-passphrase-secret.yaml > b2b-system-passphrase-secret.yaml

# NOTE, do not check delete-b2b-system-passphrase-secret.yaml into git!
rm delete-b2b-system-passphrase-secret.yaml