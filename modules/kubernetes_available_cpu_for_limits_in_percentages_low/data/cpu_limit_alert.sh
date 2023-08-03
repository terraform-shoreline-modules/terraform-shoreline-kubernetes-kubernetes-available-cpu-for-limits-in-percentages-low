

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