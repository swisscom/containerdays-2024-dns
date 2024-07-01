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

# kind create cluster --name $clustername --config cluster-0-cfg.yaml  || { echo -e "${RED}Error: Failed to create cluster${NS}"; exit 1; }
if ! kind get clusters | grep -q "^${clustername}$"; then
  echo "Error: Kind cluster '${clustername}' does not exist."
  exit 1
fi

docker pull coredns/coredns:1.11.1
kind load docker-image coredns/coredns:1.11.1 --name $clustername
docker pull infoblox/dnstools:latest
kind load docker-image infoblox/dnstools:latest --name $clustername
docker pull powerdns/pdns-auth-49
kind load docker-image powerdns/pdns-auth-49 --name $clustername
docker pull docker.io/bitnami/external-dns:0.14.2
kind load docker-image docker.io/bitnami/external-dns:0.14.2 --name $clustername
docker pull bash:latest
kind load docker-image bash:latest --name $clustername

echo "checking for external-dns"

release_exists() {
    helm list --kube-context kind-$clustername | grep -w "$RELEASE_NAME" > /dev/null 2>&1
    return $?
}

RELEASE_NAME=external-dns
if release_exists; then
    echo "Helm release '$RELEASE_NAME' is already installed. Skipping."
else
    echo "Helm release '$RELEASE_NAME' is not installed. Installing..."
    helm install --kube-context kind-$clustername $RELEASE_NAME oci://registry-1.docker.io/bitnamicharts/external-dns -f external-dns-values.yaml --set txtOwnerId=$clustername-
fi

RELEASE_NAME=coredns
if release_exists; then
    echo "Helm release '$RELEASE_NAME' is already installed. Skipping."
else
    echo "Helm release '$RELEASE_NAME' is not installed. Installing..."
  helm repo add coredns https://coredns.github.io/helm
    helm install --kube-context kind-$clustername $RELEASE_NAME coredns/coredns -f core-dns-values.yaml
fi


kubectl apply -k base/ --context kind-$clustername

# docker pull registry.k8s.io/ingress-nginx/controller:v1.10.1
# kind load docker-image registry.k8s.io/ingress-nginx/controller:v1.10.1 --name $clustername
# docker pull registry.k8s.io/ingress-nginx/kube-webhook-certgen:v1.4.1
# kind load docker-image registry.k8s.io/ingress-nginx/kube-webhook-certgen:v1.4.1 --name $clustername

# kubectl apply -f nginx-ingress.yaml --context kind-$clustername
