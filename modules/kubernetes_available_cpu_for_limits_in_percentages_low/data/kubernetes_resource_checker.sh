

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