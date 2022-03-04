
#!/usr/bin/env bash
# Set enviroment variables
# Declaring IBM SFG PROD
CLAIM_CLM=$(oc get pv -n openshift-image-registry | grep openshift-image-registry/image-registry-storage)

if [[ -z ${CLAIM_CLM} ]]; then
  echo "please make sure that the image registry IS ready"
  exit 1
fi
PVC_NAME=$(oc get pv -n openshift-image-registry | grep openshift-image-registry/image-registry-storage | awk '{print $1}')

if [[ -z ${PVC_NAME} ]]; then
  echo "please make sure that YOU HAVE A PVC"
  exit 1
fi
# working on zone & reigion  - to do improvment
METADATA_LABELS_REGION=$(oc get pv ${PVC_NAME} -o jsonpath='{ .metadata.labels.failure-domain\.beta\.kubernetes\.io\/region }')

METADATA_LABELS_ZONE=$(oc get pv ${PVC_NAME} -o jsonpath='{ .metadata.labels.failure-domain\.beta\.kubernetes\.io\/zone }')

# -------- ----- -----
NFS_SERVER_STERLING=$(oc get pv ${PVC_NAME} -o jsonpath='{ .spec.nfs.server}')

NFS_PATH_STERLING=$(oc get pv ${PVC_NAME} -o jsonpath='{ .spec.nfs.path}')

( echo "cat <<EOF" ; cat sterlingtoolkit-pv.yaml_template ;) | \
METADATA_LABELS_REGION=${METADATA_LABELS_REGION} \
METADATA_LABELS_ZONE=$METADATA_LABELS_ZONE \
NFS_SERVER_STERLING=${NFS_SERVER_STERLING} \
NFS_PATH_STERLING=${NFS_PATH_STERLING} \
sh > sterlingtoolkit-pv.yaml
