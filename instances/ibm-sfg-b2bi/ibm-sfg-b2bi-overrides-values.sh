#!/usr/bin/env bash
# Set enviroment variables
# Declaring IBM SFG PROD

SFG_REPO=${SFG_REPO:-"cp.icr.io/cp/ibm-sfg/sfg"}
SFG_TAG=${SFG_TAG:-"6.1.0.0"}
SFG_PULLSECRECT=${SFG_PULLSECRECT:-"ibm-entitlement-key"}
APP_RESOURCES_PVC_ENABLED=${APP_RESOURCES_PVC_ENABLED:-"true"}
APP_DOCUMENTS_PVC_ENABLED=${APP_DOCUMENTS_PVC_ENABLED:-"true"}
DATASETUP_ENABLED=${DATASETUP_ENABLED:-"true"}
DBHOST=$(oc get svc db2-lb -n db2 -o jsonpath='{ .status.loadBalancer.ingress[0].ip}')
DBPORT=$(oc get svc db2-lb -n db2 -o jsonpath='{ .spec.ports[0].port}')
DBDATA=${DBDATA:-"B2BIDB"}
DBCREATESCHEMA=${DBCREATESCHEMA:-"true"}
JMSHOST=$(oc get svc mq-data -n mq -o jsonpath='{ .spec.clusterIP}')
JMSPORT=$(oc get svc mq-data -n mq -o jsonpath='{ .spec.ports[0].port}')
JMSCONNECTIONNAMELIST="$JMSHOST($JMSPORT)"
JSMCHANNEL=${JSMCHANNEL:-"DEV.APP.SVRCONN"}
INGRESS_INTERNAL_HOST_ASI="asi."$(oc get dns cluster -o jsonpath='{ .spec.baseDomain }')
INGRESS_INTERNAL_HOST_AC="ac."$(oc get dns cluster -o jsonpath='{ .spec.baseDomain }')
INGRESS_INTERNAL_HOST_API="api."$(oc get dns cluster -o jsonpath='{ .spec.baseDomain }')
PURGE_IMG_REPO=${PURGE_IMG_REPO:-"cp.icr.io/cp/ibm-sfg/sfg-purge"}
PURGE_IMG_TAG=${PURGE_IMG_TAG:-"6.1.0.0"}
PURGE_PULLSECRET=${PURGE_PULLSECRET:-"ibm-entitlement-key"}

# Create Kubernetes yaml
( echo "cat <<EOF" ; cat ibm-sfg-b2bi-overrides-values.yaml_template ;) | \
SFG_REPO=${SFG_REPO} \
SFG_TAG=${SFG_TAG} \
SFG_PULLSECRECT=${SFG_PULLSECRECT} \
APP_RESOURCES_PVC_ENABLED=${APP_RESOURCES_PVC_ENABLED} \
APP_DOCUMENTS_PVC_ENABLED=${APP_DOCUMENTS_PVC_ENABLED} \
DATASETUP_ENABLED=${DATASETUP_ENABLED} \
DBHOST=${DBHOST} \
DBPORT=${DBPORT} \
DBDATA=${DBDATA} \
DBCREATESCHEMA=${DBCREATESCHEMA} \
JMSHOST=${JMSHOST} \
JMSPORT=${JMSPORT} \
JMSCONNECTIONNAMELIST=${JMSCONNECTIONNAMELIST} \
JSMCHANNEL=${JSMCHANNEL} \
INGRESS_INTERNAL_HOST_ASI=${INGRESS_INTERNAL_HOST_ASI} \
INGRESS_INTERNAL_HOST_AC=${INGRESS_INTERNAL_HOST_AC} \
INGRESS_INTERNAL_HOST_API=${INGRESS_INTERNAL_HOST_API} \
PURGE_IMG_REPO=${PURGE_IMG_REPO} \
PURGE_IMG_TAG=${PURGE_IMG_TAG} \
PURGE_PULLSECRET=${PURGE_PULLSECRET} \
sh > values.yaml
