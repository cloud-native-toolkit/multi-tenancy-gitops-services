#!/usr/bin/env bash
# Set enviroment variables

if [[ -z ${ADMIN_EMAIL_ADDRESS} ]]; then
  echo "Please provide environment variable ADMIN_EMAIL_ADDRESS"
  exit 1
fi
if [[ -z ${EMAIL_HOST_NAME} ]]; then
  echo "Please provide environment variable EMAIL_HOST_NAME"
  exit 1
fi
if [[ -z ${EMAIL_PORT} ]]; then
  echo "Please provide environment variable EMAIL_PORT"
  exit 1
fi
if [[ -z ${EMAIL_USER} ]]; then
  echo "Please provide environment variable EMAIL_USER"
  exit 1
fi
if [[ -z ${EMAIL_RESPOND} ]]; then
  echo "Please provide environment variable EMAIL_RESPOND"
  exit 1
fi
if [[ -z ${CC_ADMIN_EMAIL_ADDRESS} ]]; then
  echo "Please provide environment variable CC_ADMIN_EMAIL_ADDRESS"
  exit 1
fi
if [[ -z ${KEY_ALIAS} ]]; then
  echo "Please provide environment variable KEY_ALIAS"
  exit 1
fi

NS="sccm"

SCCM_REPO=${SCCM_REPO:-"cp.icr.io/cp/ibm-scc/ibmscc"}
SCCM_TAG=${SCCM_TAG:-"621_ifix06"}
SCCM_PULLSECRECT=${SCCM_PULLSECRECT:-"ibm-entitlement-key"}
DBTYPE=${DBTYPE:-"DB2"}
DBHOST=$(oc get svc db2-lb -n ${NS} -o jsonpath='{ .spec.clusterIP}')
DBPORT=$(oc get svc db2-lb -n ${NS} -o jsonpath='{ .spec.ports[0].port}')
DBDATA=${DBDATA:-"SCCDB"}
DBUSER=${DBUSER:-"db2inst1"}
DBDRIVER=${DBDRIVER:-"/app/CC/user_inputs/db2jcc4.jar"}

CLUSTER_DOMAIN=$(oc get dns cluster -o jsonpath='{ .spec.baseDomain }')

# Create Kubernetes yaml
( echo "cat <<EOF" ; cat ibm-sccm-overrides-values.yaml_template ;) | \
SCCM_REPO=\"${SCCM_REPO}\" \
SCCM_TAG=\"${SCCM_TAG}\" \
SCCM_PULLSECRECT=\"${SCCM_PULLSECRECT}\" \
DBTYPE=\"${DBTYPE}\" \
DBHOST=\"${DBHOST}\" \
DBPORT=\"${DBPORT}\" \
DBDATA=\"${DBDATA}\" \
DBUSER=\"${DBUSER}\" \
DBDRIVER=\"${DBDRIVER}\" \
CLUSTER_DOMAIN=\"${CLUSTER_DOMAIN}\" \
EMAIL_HOST_NAME=\"${EMAIL_HOST_NAME}\" \
EMAIL_PORT=\"${EMAIL_PORT}\" \
EMAIL_USER=\"${EMAIL_USER}\" \
EMAIL_RESPOND=\"${EMAIL_RESPOND}\" \
CC_ADMIN_EMAIL_ADDRESS=\"${CC_ADMIN_EMAIL_ADDRESS}\" \
KEY_ALIAS=\"${KEY_ALIAS}\" \
ADMIN_EMAIL_ADDRESS=\"${ADMIN_EMAIL_ADDRESS}\" \
sh > values.yaml
