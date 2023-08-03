

#!/bin/bash



# Set variables

NAMESPACE=${NAMESPACE}

POD_SELECTOR=${SELECTOR_FOR_THE_AFFECTED_PODS}



# Increase CPU limits for the affected pods

kubectl -n $NAMESPACE patch pod -l $POD_SELECTOR --type=json -p='[{"op": "replace", "path": "/spec/containers/0/resources/limits/cpu", "value":{"cpu": "1"}}]'