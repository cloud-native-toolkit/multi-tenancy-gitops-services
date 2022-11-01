#!/bin/bash

INGRESS_DOMAIN=$(oc get IngressController default -n openshift-ingress-operator -o jsonpath='{.status.domain}')
NAMESPACE=${NAMESPACE:-"cp4ba"}

( echo "cat <<EOF" ; cat cloud-pak-dashboard.yaml_template ;) | \
INGRESS_DOMAIN=${INGRESS_DOMAIN} \
NAMESPACE=${NAMESPACE} \
sh > cloud-pak-dashboard.yaml

( echo "cat <<EOF" ; cat decision-center.yaml_template ;) | \
INGRESS_DOMAIN=${INGRESS_DOMAIN} \
NAMESPACE=${NAMESPACE} \
sh > decision-center.yaml

( echo "cat <<EOF" ; cat decision-runner.yaml_template ;) | \
INGRESS_DOMAIN=${INGRESS_DOMAIN} \
NAMESPACE=${NAMESPACE} \
sh > decision-runner.yaml

( echo "cat <<EOF" ; cat decision-server-console.yaml_template ;) | \
INGRESS_DOMAIN=${INGRESS_DOMAIN} \
NAMESPACE=${NAMESPACE} \
sh > decision-server-console.yaml


( echo "cat <<EOF" ; cat decision-server-runtime.yaml_template ;) | \
INGRESS_DOMAIN=${INGRESS_DOMAIN} \
NAMESPACE=${NAMESPACE} \
sh > decision-server-runtime.yaml
