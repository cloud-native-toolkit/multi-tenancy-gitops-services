#!/bin/bash
#
# You need to run this script for each namespace.
#
# This script takes one argument; the namespace where the chart will be installed.
#
# Example:
#     ./deleteSecurityNamespacePrereqs.sh myNamespace
#

if [ "$#" -lt 1 ]; then
	echo "Usage: deleteSecurityNamespacePrereqs.sh NAMESPACE"
  exit 1
fi

namespace=$1

[[ $(dirname $0 | cut -c1) = '/' ]] && scriptDir=$(dirname $0)/ || scriptDir=$(pwd)/$(dirname $0)/

cd ${scriptDir}
source ../../common/kubhelper.sh

kubectl get namespace $namespace &> /dev/null
if [ $? -ne 0 ]; then 
    echo "ERROR: Namespace $namespace does not exist."
    exit 1
fi
isApplied="false"
if supports_scc; then
    echo "Removing all namespace users from SecurityContextConstraints"
    if command -v oc >/dev/null 2>&1 ; then
        # Note: this script only works on OpenShift >= 3.11, otherwise you must run the following command manually
        oc adm policy remove-scc-from-group ibm-ssp-cm-scc system:serviceaccounts:$namespace
    else
        echo "ERROR:  The OpenShift CLI is not available..."
    fi
	isApplied="true"
fi

if supports_psp; then
    # Replace the NAMESPACE tag with the namespace specified in a temporary yaml file.
	if [ "$isApplied" == "false" ]; then
		sed 's/{{ NAMESPACE }}/'$namespace'/g' ../../pre-install/namespaceAdministration/ibm-ssp-cm-rb.yaml > $namespace-ibm-ssp-cm-rb.yaml

		# Delete the role binding for all service accounts in the current namespace
		kubectl delete -f $namespace-ibm-ssp-cm-rb.yaml -n $namespace

		# Clean up - delete the temporary yaml file.
		rm $namespace-ibm-ssp-cm-rb.yaml
	fi
fi
