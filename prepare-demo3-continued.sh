#!/bin/bash

# Get the directory of the current script
SCRIPT_DIR=$(dirname "$0")

# Create 3 kind clusters
"$SCRIPT_DIR/create-kind-clusters.sh" 2

DEPLOYMENT_NAME="coredns"
NAMESPACE="kube-system"
while true; do
  # Check if the deployment is ready
  READY_REPLICAS=$(kubectl --context kind-dns-1 get deployment $DEPLOYMENT_NAME -n $NAMESPACE -o jsonpath='{.status.readyReplicas}')
  DESIRED_REPLICAS=$(kubectl --context kind-dns-1 get deployment $DEPLOYMENT_NAME -n $NAMESPACE -o jsonpath='{.status.replicas}')
  
  if [[ "$READY_REPLICAS" == "$DESIRED_REPLICAS" ]] && [[ "$READY_REPLICAS" -gt 0 ]]; then
    echo "Deployment $DEPLOYMENT_NAME is ready."
    break
  else
    echo "Waiting... Ready replicas: $READY_REPLICAS / $DESIRED_REPLICAS"
    sleep 5
  fi
done

# Deploy the multicluster dns in all 2 clusters
"$SCRIPT_DIR/setup-kind.sh" 0
"$SCRIPT_DIR/setup-kind.sh" 1
