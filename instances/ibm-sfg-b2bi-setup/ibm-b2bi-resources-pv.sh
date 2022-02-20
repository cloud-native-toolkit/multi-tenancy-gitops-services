
   #!/usr/bin/env bash
# Set enviroment variables
# Declaring IBM SFG PROD

# Paramtraize storage class
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
NFS_SERVER_RES=$(oc get pv ${PVC_NAME} -o jsonpath='{ .spec.nfs.server}')

NFS_PATH_RES=$(oc get pv ${PVC_NAME} -o jsonpath='{ .spec.nfs.path}/resources')

( echo "cat <<EOF" ; cat ibm-b2bi-resources-pv.yaml_template ;) | \
NFS_SERVER_RES=${NFS_SERVER_RES} \
NFS_PATH_RES=${NFS_PATH_RES} \
sh > ibm-b2bi-resources-pv.yaml