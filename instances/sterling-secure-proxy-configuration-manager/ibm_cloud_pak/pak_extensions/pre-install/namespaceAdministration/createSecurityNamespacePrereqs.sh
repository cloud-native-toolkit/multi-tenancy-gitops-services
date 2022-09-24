#!/bin/bash
#
# You need to run this script for each namespace.
#
# This script takes one argument; the namespace where the chart will be installed.
#
# Example:
#     ./createSecurityNamespacePrereqs.sh myNamespace
#
[[ $(dirname $0 | cut -c1) = '/' ]] && scriptDir=$(dirname $0)/ || scriptDir=$(pwd)/$(dirname $0)/

if [ "$#" -lt 1 ]; then
	echo "Usage: createSecurityNamespacePrereqs.sh NAMESPACE"
  exit 1
fi

namespace=$1
kubectl get namespace $namespace &> /dev/null
if [ $? -ne 0 ]; then
  echo "ERROR: Namespace $namespace does not exist."
  exit 1
fi
cd ${scriptDir}
. ../../common/kubhelper.sh

isApplied="false"
if supports_scc; then
    echo "Adding all namespace users to SCC..."
    if command -v oc >/dev/null 2>&1 ; then
    # Note: this script only works on OpenShift >= 3.11, otherwise you must run the following command manually
      oc adm policy add-scc-to-group ibm-ssp-cm-scc system:serviceaccounts:$namespace
    else
      echo "ERROR:  The OpenShift CLI is not available..."
    fi
    isApplied="true"
fi

if supports_psp; then
    if [ "$isApplied" == "false" ]; then
    # Replace the NAMESPACE tag with the namespace specified in a temporary yaml file.
    sed 's/{{ NAMESPACE }}/'$namespace'/g' ibm-ssp-cm-rb.yaml > $namespace-ibm-ssp-cm-rb.yaml

    echo "Adding a RoleBinding for all namespace users to the PSP..."
    # Create the role binding for all service accounts in the current namespace
    kubectl create -f $namespace-ibm-ssp-cm-rb.yaml -n $namespace

    # Clean up - delete the temporary yaml file.
    rm $namespace-ibm-ssp-cm-rb.yaml
    fi
fi
