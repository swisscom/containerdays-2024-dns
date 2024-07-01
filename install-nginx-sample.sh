#!/bin/bash

# Check if cluster name is provided
if [ -z "$1" ]; then
  echo -e "${RED}Error: No cluster name provided${NC}"
  echo "Usage: $0 <clustername>"
  exit 1
fi

clustername=$1

kind load docker-image nginx:latest --name $clustername
docker pull nginx
kubectl apply -f nginx.yaml --context kind-$clustername
