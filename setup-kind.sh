#!/bin/bash

set -e
# Define colors
RED='\033[0;31m'
NC='\033[0m' # No Color

ns=dns

# Check if id of cluster is porvided
if [ -z "$1" ]; then
  echo -e "${RED}Error: Id of cluster to setup not provided${NC}"
  echo "Usage: $0 <id_of_cluster> [clusternameprefix]"
  exit 1
fi

# Check if the first parameter is a number
re='^[0-9]+$'
if ! [[ $1 =~ $re ]] ; then
   echo -e "${RED}Error: '$1' is not a number${NC}" >&2; exit 1
fi

this_cluster_id=$1
clusternameprefix=${2:-dns}  # Set default cluster name to 'dns' if not provided

clustername="${clusternameprefix}-$this_cluster_id"

# kind create cluster --name $clustername --config cluster-0-cfg.yaml  || { echo -e "${RED}Error: Failed to create cluster${NS}"; exit 1; }
if ! kind get clusters | grep -q "^${clustername}$"; then
  echo "Error: Kind cluster '${clustername}' does not exist."
  exit 1
fi

pull_image_if_not_exists() {
  local image=$1
  local version=$2
  if ! docker image list | grep $image | grep $version; then
    docker pull "$image:$version"
  else
    echo "Image $image already exists locally. Skipping pull."
  fi
}

pull_image_if_not_exists coredns/coredns "1.11.1"
kind load docker-image coredns/coredns:1.11.1 --name $clustername

pull_image_if_not_exists infoblox/dnstools "latest"
kind load docker-image infoblox/dnstools:latest --name $clustername

pull_image_if_not_exists registry.k8s.io/e2e-test-images/jessie-dnsutils 1.3
kind load docker-image registry.k8s.io/e2e-test-images/jessie-dnsutils:1.3 --name $clustername

pull_image_if_not_exists powerdns/pdns-auth-49 "latest"
kind load docker-image powerdns/pdns-auth-49 --name $clustername

pull_image_if_not_exists bitnami/external-dns "0.14.2"
kind load docker-image bitnami/external-dns:0.14.2 --name $clustername

pull_image_if_not_exists bash "latest"
kind load docker-image bash:latest --name $clustername

pull_image_if_not_exists nginx "latest"
kind load docker-image nginx:latest --name $clustername

echo "checking for external-dns"

release_exists() {
    helm list --kube-context kind-$clustername --namespace $ns | grep -w "$RELEASE_NAME" > /dev/null 2>&1
    return $?
}

get_ipv4_address() {
  local container_name=$1

  docker network inspect kind | jq -r --arg name "$container_name" '.[] | .Containers[] | select(.Name == $name) | .IPv4Address' | cut -d'/' -f1
}

clusters=$(kind get clusters)
external_dns_chart_version="8.3.3"

for cluster in $clusters; do
  # Extract the last character of the cluster name as the cluster ID
  cluster_id=${cluster: -1}
  
  values_file="templates/external-dns-values.yaml"
  config_folder="tmp/cluster-$this_cluster_id"
  mkdir -p $config_folder
  tmp_config="$config_folder/external-dns-values-$cluster_id.yaml"

  # Make a temporary copy of the configuration file
  cp "$values_file" "$tmp_config"

  echo "before $cluster_id $this_cluster_id and dns is $ns"

  # Modify txtOwnerId in the copied config file for each external-dns instance
  sed -i'' -e "s|txtOwnerId: \"dns-\"|txtOwnerId: \"dns-$cluster_id\"|g" "$tmp_config"
  rm "$tmp_config"-e

  if [ "$cluster_id" != "$this_cluster_id" ]; then
    # Modify apiServerPort in the copied config file
    echo "Modifying apiServerPort in the copied config file and the namespace is $ns"
    ipv4_address=$(get_ipv4_address "dns-$cluster_id-control-plane")
    sed -i'' -e "s|value: \"http://pdns-service.default.svc.cluster.local:8081\"|value: http://$ipv4_address:30004|g" "$tmp_config"
    rm "$tmp_config"-e
    sed -i'' -e "s|apiUrl: http://pdns-service.default.svc.cluster.local|apiUrl: http://$ipv4_address|g" "$tmp_config"
    sed -i'' -e "s|apiPort: 8081|apiPort: 30004|g" "$tmp_config"
    rm "$tmp_config"-e
  else
    echo "Modifying apiServerPort in the copied config file and the namespace is $ns"
    sed -i'' -e "s|value: \"http://pdns-service.default.svc.cluster.local:8081\"|value: http://pdns-service.$ns.svc.cluster.local:8081|g" "$tmp_config"
    rm "$tmp_config"-e
    sed -i'' -e "s|apiUrl: http://pdns-service.default.svc.cluster.local|apiUrl: http://pdns-service.$ns.svc.cluster.local|g" "$tmp_config"
    rm "$tmp_config"-e
  fi

  kubectl apply -k base/ --context kind-$clustername
  kubectl apply -f https://raw.githubusercontent.com/kubernetes-sigs/external-dns/v0.14.2/charts/external-dns/crds/dnsendpoint.yaml --context kind-$clustername

  RELEASE_NAME=external-dns-$cluster_id
  if release_exists; then
    echo "Helm release '$RELEASE_NAME' is already installed. Skipping."
  else
    echo "Helm release '$RELEASE_NAME' is not installed. Installing..."
    helm install --namespace $ns --kube-context kind-$clustername $RELEASE_NAME oci://registry-1.docker.io/bitnamicharts/external-dns --version $external_dns_chart_version -f $tmp_config --set txtOwnerId=$clustername-
  fi
  # Create a rolebinding for the external-dns service account to allow read of the dnsendpoints crd
  kubectl --context kind-$clustername create clusterrolebinding dnsendpoint-read-binding-$cluster_id --namespace=dns --clusterrole=dnsendpoint-read --serviceaccount=dns:external-dns-$cluster_id
done

values_file="templates/core-dns-values.yaml"
config_folder="tmp/cluster-$this_cluster_id"
mkdir -p $config_folder
tmp_config="$config_folder/core-dns-values.yaml"
cp "$values_file" "$tmp_config"

for cluster in $clusters; do
  # Extract the last character of the cluster name as the cluster ID
  cluster_id=${cluster: -1}

  if [ "$cluster_id" != "$this_cluster_id" ]; then
    # Modify apiServerPort in the copied config file
    ipv4_address=$(get_ipv4_address "dns-$cluster_id-control-plane")
    sed -i'' -e "/parameters: 5gc.3gppnetwork.org. 10.96.0.12/ s/$/ $ipv4_address:30003/" "$tmp_config"
    rm "$tmp_config"-e
  fi
done

RELEASE_NAME=coredns
if release_exists; then
    echo "Helm release '$RELEASE_NAME' is already installed. Skipping."
else
    echo "Helm release '$RELEASE_NAME' is not installed. Installing..."
    helm repo add coredns https://coredns.github.io/helm
    helm install --namespace $ns --kube-context kind-$clustername $RELEASE_NAME coredns/coredns -f $tmp_config
fi





# docker pull registry.k8s.io/ingress-nginx/controller:v1.10.1
# kind load docker-image registry.k8s.io/ingress-nginx/controller:v1.10.1 --name $clustername
# docker pull registry.k8s.io/ingress-nginx/kube-webhook-certgen:v1.4.1
# kind load docker-image registry.k8s.io/ingress-nginx/kube-webhook-certgen:v1.4.1 --name $clustername

# kubectl apply -f nginx-ingress.yaml --context kind-$clustername
