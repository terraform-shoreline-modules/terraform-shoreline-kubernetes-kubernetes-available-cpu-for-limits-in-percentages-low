
### About Shoreline
The Shoreline platform provides real-time monitoring, alerting, and incident automation for cloud operations. Use Shoreline to detect, debug, and automate repairs across your entire fleet in seconds with just a few lines of code.

Shoreline Agents are efficient and non-intrusive processes running in the background of all your monitored hosts. Agents act as the secure link between Shoreline and your environment's Resources, providing real-time monitoring and metric collection across your fleet. Agents can execute actions on your behalf -- everything from simple Linux commands to full remediation playbooks -- running simultaneously across all the targeted Resources.

Since Agents are distributed throughout your fleet and monitor your Resources in real time, when an issue occurs Shoreline automatically alerts your team before your operators notice something is wrong. Plus, when you're ready for it, Shoreline can automatically resolve these issues using Alarms, Actions, Bots, and other Shoreline tools that you configure. These objects work in tandem to monitor your fleet and dispatch the appropriate response if something goes wrong -- you can even receive notifications via the fully-customizable Slack integration.

Shoreline Notebooks let you convert your static runbooks into interactive, annotated, sharable web-based documents. Through a combination of Markdown-based notes and Shoreline's expressive Op language, you have one-click access to real-time, per-second debug data and powerful, fleetwide repair commands.

### What are Shoreline Op Packs?
Shoreline Op Packs are open-source collections of Terraform configurations and supporting scripts that use the Shoreline Terraform Provider and the Shoreline Platform to create turnkey incident automations for common operational issues. Each Op Pack comes with smart defaults and works out of the box with minimal setup, while also providing you and your team with the flexibility to customize, automate, codify, and commit your own Op Pack configurations.

# Kubernetes - Available CPU for Limits in percentages Low
---

This incident type relates to a situation where the available CPU for limits in percentages in a Kubernetes cluster is low. The incident is triggered when a container uses more CPU resources than its specified request and limits, eventually leading to resource exhaustion. This can cause service disruptions and impact the performance of the Kubernetes cluster. The incident requires immediate attention to prevent further degradation of service quality.

### Parameters
```shell
# Environment Variables

export POD_NAME="PLACEHOLDER"

export NAMESPACE="PLACEHOLDER"

export DEPLOYMENT_NAME="PLACEHOLDER"

export CONTAINER_NAME="PLACEHOLDER"

export SELECTOR_FOR_THE_AFFECTED_PODS="PLACEHOLDER"

export NUMBER_OF_NODES_TO_ADD="PLACEHOLDER"
```

## Debug

### Check the Kubernetes cluster status
```shell
kubectl cluster-info
```

### Check the status of the Kubernetes nodes
```shell
kubectl get nodes
```

### Check the status of the Kubernetes pods
```shell
kubectl get pods
```

### Check the CPU resources for the Kubernetes nodes
```shell
kubectl describe nodes | grep -i cpu
```

### Check the CPU resources for the Kubernetes pods
```shell
kubectl describe pods ${POD_NAME} | grep -i cpu
```

### Check the resource limits for the Kubernetes pods
```shell
kubectl describe pods ${POD_NAME} | grep -i limits
```

### Check the CPU usage for the Kubernetes pods
```shell
kubectl top pods
```

### Check the resource requests for the Kubernetes pods
```shell
kubectl describe pods ${POD_NAME} | grep -i requests
```

### Check the CPU usage of the Kubernetes nodes
```shell
kubectl top nodes
```

### Heavy load on the Kubernetes cluster which has caused the CPU usage to spike and exceed the limits set in place.
```shell


#!/bin/bash



# Set the namespace for the deployment

NAMESPACE=${NAMESPACE}



# Set the deployment name

DEPLOYMENT=${DEPLOYMENT_NAME}



# Get the CPU usage for the deployment

CPU_USAGE=$(kubectl top pods -n $NAMESPACE | grep $DEPLOYMENT | awk '{print $2}')



# Get the CPU limit for the deployment

CPU_LIMIT=$(kubectl describe deployment $DEPLOYMENT -n $NAMESPACE | grep -i cpu | awk '{print $3}')



# Compare the CPU usage to the CPU limit

if (( $(echo "$CPU_USAGE > $CPU_LIMIT" |bc -l) )); then

    # Alert that the CPU usage has exceeded the limit

    echo "CPU usage for deployment $DEPLOYMENT in namespace $NAMESPACE has exceeded the limit of $CPU_LIMIT."

else

    # Alert that the CPU usage is within the limit

    echo "CPU usage for deployment $DEPLOYMENT in namespace $NAMESPACE is within the limit of $CPU_LIMIT."

fi


```

### Misconfiguration of Kubernetes resources such as incorrect CPU limit values or not enough resources allocated to the cluster.
```shell


#!/bin/bash



# Set variables

NAMESPACE=${NAMESPACE}

CONTAINER=${CONTAINER_NAME}



# Check if kubectl is installed

if ! command -v kubectl &> /dev/null

then

    echo "kubectl could not be found. Please install kubectl and try again."

    exit 1

fi



# Check if namespace exists

if ! kubectl get namespace $NAMESPACE &> /dev/null

then

    echo "Namespace $NAMESPACE not found. Please specify the correct namespace name."

    exit 1

fi



# Check if container exists in the namespace

if ! kubectl get pod -n $NAMESPACE -o jsonpath="{.items[*].metadata.name}" | grep $CONTAINER &> /dev/null

then

    echo "Container $CONTAINER not found in namespace $NAMESPACE. Please specify the correct container name."

    exit 1

fi



# Get CPU limits and requests for the container

CPU_LIMITS=$(kubectl get pod -n $NAMESPACE -o jsonpath="{.items[*].spec.containers[?(@.name=='$CONTAINER')].resources.limits.cpu}")

CPU_REQUESTS=$(kubectl get pod -n $NAMESPACE -o jsonpath="{.items[*].spec.containers[?(@.name=='$CONTAINER')].resources.requests.cpu}")



# Check if CPU limits and requests are correctly configured

if [ -z "$CPU_LIMITS" ] || [ -z "$CPU_REQUESTS" ] || [ "$CPU_LIMITS" -lt "$CPU_REQUESTS" ]

then

    echo "Misconfigured Kubernetes resources detected. CPU limits and requests are either not set or set incorrectly."

    exit 1

fi



echo "No issues detected with Kubernetes resources configuration."

exit 0


```

## Repair

### Increase the CPU limits for the affected Kubernetes Pods: Insufficient CPU limits may cause this incident. Increasing the limits can help address the issue.
```shell


#!/bin/bash



# Set variables

NAMESPACE=${NAMESPACE}

POD_SELECTOR=${SELECTOR_FOR_THE_AFFECTED_PODS}



# Increase CPU limits for the affected pods

kubectl -n $NAMESPACE patch pod -l $POD_SELECTOR --type=json -p='[{"op": "replace", "path": "/spec/containers/0/resources/limits/cpu", "value":{"cpu": "1"}}]'


```

### Add more CPU resources to the Kubernetes cluster: If the cluster is already running at maximum capacity and the CPU limits are set appropriately, you may need to add more CPU resources to the cluster to avoid this incident.
```shell


#!/bin/bash



# Set variables

KUBECONFIG=${PATH_TO_KUBECONFIG_FILE} # e.g. /home/user/kubeconfig.yaml

NODES=${NUMBER_OF_NODES_TO_ADD} # e.g. 2



# Increase CPU resources in Kubernetes cluster

kubectl --replicas=$NODES deployment/kube-system/kube-dns

kubectl scale --replicas=$NODES deployment/kube-system/kube-proxy


```