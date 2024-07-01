#!/bin/bash

set -e
# Define colors
RED='\033[0;31m'
NC='\033[0m' # No Color

# Check if cluster name is provided
if [ -z "$1" ]; then
  echo -e "${RED}Error: No cluster name provided${NC}"
  echo "Usage: $0 <clustername>"
  exit 1
fi

clustername=$1

kind create cluster --name $clustername-0 --config cluster-0-cfg.yaml  || { echo -e "${RED}Error: Failed to create cluster${NS}"; exit 1; }
kind create cluster --name $clustername-1 --config cluster-1-cfg.yaml  || { echo -e "${RED}Error: Failed to create cluster${NS}"; exit 1; }
kind create cluster --name $clustername-2 --config cluster-2-cfg.yaml  || { echo -e "${RED}Error: Failed to create cluster${NS}"; exit 1; }
