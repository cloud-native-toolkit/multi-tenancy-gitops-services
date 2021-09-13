# Cloud Native Toolkit Operators and Instances Catalog for GitOps

This git repository serves as a catalog/library of Operators and Instances of the custom resource(s) provided by the Operators for the [GitOps workflow](https://github.com/cloud-native-toolkit/multi-tenancy-gitops).  The Operator and Instance YAMLs are package as a Helm Chart and can be referenced by ArgoCD Applications.

The Charts are hosted in the [Cloud Native Toolkit Helm Repository](https://github.com/cloud-native-toolkit/toolkit-charts).



### References
- This repository shows the reference architecture for gitops directory structure for more info https://cloudnativetoolkit.dev/adopting/use-cases/gitops/gitops-ibm-cloud-paks



## Instances

### Instana
The prerequisites to install the Instana agent are:  
    
1. Store your Instana Agent Key in a secret in the `instana-agent` namespace. The secret key field should contain `key` and the value contains your Instana Agent Key. Modify the `instana-agent.agent.keysSecret` value in the `instances\instana-agent\values.yaml` file to match the secret you deployed. 

1. Modify the `instana-agent.cluster.name` value in the `instances\instana-agent\values.yaml` file which represents the name that will be assigned to this cluster in Instana.

1. Modify the `instana-agent.zone.name` value in the `instances\instana-agent\values.yaml` file which is the custom zone that detected technologies will be assigned to.
