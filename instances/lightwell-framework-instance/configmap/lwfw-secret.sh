#!/usr/bin/env bash

SEALED_SECRET_NAMESPACE=${SEALED_SECRET_NAMESPACE:-sealed-secrets}
SEALED_SECRET_CONTOLLER_NAME=${SEALED_SECRET_CONTOLLER_NAME:-sealed-secrets}

# Create Kubernetes Secret yaml
oc create secret generic lw-app-prop \
--from-file=./application.properties \
--from-file=./customer_LW_license.properties \
--from-file=./portal.key \
--from-file=./encryption.key \
--dry-run=client -o yaml > delete-lw-app-prop-secret.yaml

# Encrypt the secret using kubeseal and private key from the cluster
kubeseal -n b2bi-prod --controller-name=${SEALED_SECRET_CONTOLLER_NAME} --controller-namespace=${SEALED_SECRET_NAMESPACE} -o yaml < delete-lw-app-prop-secret.yaml > lw-app-prop-secret.yaml

# NOTE, do not check delete-lw-app-prop.yaml into git!
#rm delete-lw-app-prop.yaml