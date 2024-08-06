#!/bin/bash

# Get the directory of the current script
SCRIPT_DIR=$(dirname "$0")

# Destroy the single kind cluster
"$SCRIPT_DIR/destroy-kind.sh" 1

# Create 1 kind clusters
"$SCRIPT_DIR/create-kind-clusters.sh" 1
# Deploy the multicluster dns in all 3 clusters
"$SCRIPT_DIR/setup-kind.sh" 0

# Remove the coredns debloyment in dns namespace for first demo
kubectl --context kind-dns-0 delete deployment coredns -n dns
