

#!/bin/bash



# Set variables

KUBECONFIG=${PATH_TO_KUBECONFIG_FILE} # e.g. /home/user/kubeconfig.yaml

NODES=${NUMBER_OF_NODES_TO_ADD} # e.g. 2



# Increase CPU resources in Kubernetes cluster

kubectl --replicas=$NODES deployment/kube-system/kube-dns

kubectl scale --replicas=$NODES deployment/kube-system/kube-proxy