#!/bin/bash
#
# You need to run this script once prior to installing the chart.
#

[[ $(dirname $0 | cut -c1) = '/' ]] && scriptDir=$(dirname $0)/ || scriptDir=$(pwd)/$(dirname $0)/

cd ${scriptDir}
. ../../common/kubhelper.sh

isApplied="false"
if supports_scc; then
  # Create the Security Context Constraints
  echo "Creating SecurityContextConstraints"
  kubectl create -f ibm-ssp-cm-scc.yaml --validate=false
  echo "Creating Cluster Role"
  kubectl create -f ibm-ssp-cm-cr-scc.yaml --validate=false
  isApplied=true
fi

if supports_psp; then
  # Create the PodSecurityPolicy and ClusterRole for all releases of this chart.
  if [ "$isApplied" == "false" ]; then
    echo "Creating Pod Security Policy"
    kubectl create -f ibm-ssp-cm-psp.yaml
    echo "Creating Cluster Role"
    kubectl create -f ibm-ssp-cm-cr.yaml
  fi
fi
