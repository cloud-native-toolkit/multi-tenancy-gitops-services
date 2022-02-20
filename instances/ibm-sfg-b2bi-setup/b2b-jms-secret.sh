#!/usr/bin/env bash

# Set variables
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

JMS_PASSWORD=${JMS_PASSWORD}
JMS_KEYSTORE_PASSWORD=${JMS_KEYSTORE_PASSWORD}
JMS_TRUSTSTORE_PASSWORD=${JMS_TRUSTSTORE_PASSWORD}

SEALED_SECRET_NAMESPACE=${SEALED_SECRET_NAMESPACE:-sealed-secrets}
SEALED_SECRET_CONTOLLER_NAME=${SEALED_SECRET_CONTOLLER_NAME:-sealed-secrets}

# Create Kubernetes Secret yaml
oc create secret generic b2b-jms-secret --type=Opaque \
--from-literal=JMS_USERNAME=app \
--from-literal=JMS_PASSWORD=${JMS_PASSWORD} \
--from-literal=JMS_KEYSTORE_PASSWORD=${JMS_KEYSTORE_PASSWORD} \
--from-literal=JMS_TRUSTSTORE_PASSWORD=${JMS_TRUSTSTORE_PASSWORD} \
--dry-run=client -o yaml > delete-b2b-jms-secret-secret.yaml

# Encrypt the secret using kubeseal and private key from the cluster
kubeseal -n tools --controller-name=${SEALED_SECRET_CONTOLLER_NAME} --controller-namespace=${SEALED_SECRET_NAMESPACE} -o yaml < delete-b2b-jms-secret-secret.yaml > b2b-jms-secret-secret.yaml

# NOTE, do not check delete-b2b-jms-secret-secret.yaml into git!
rm delete-b2b-jms-secret-secret.yaml