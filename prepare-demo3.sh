#!/bin/bash

# Get the directory of the current script
SCRIPT_DIR=$(dirname "$0")

# Destroy the single kind cluster
"$SCRIPT_DIR/destroy-kind.sh" 1
# Create 3 kind clusters
"$SCRIPT_DIR/create-kind-clusters.sh" 3
# Deploy the multicluster dns in all 3 clusters
"$SCRIPT_DIR/setup-kind.sh" 0
"$SCRIPT_DIR/setup-kind.sh" 1
"$SCRIPT_DIR/setup-kind.sh" 2
