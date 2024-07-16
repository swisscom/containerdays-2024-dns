#!/bin/bash

set -e
# Define colors
RED='\033[0;31m'
NC='\033[0m' # No Color

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

id_of_clusters=$1
clusternameprefix=${2:-dns}  # Set default cluster name to 'dns' if not provided

clustername="${clusternameprefix}-$id_of_clusters"

if ! kind get clusters | grep -q "^${clustername}$"; then
  echo "Error: Kind cluster '${clustername}' does not exist."
  exit 1
fi

release_exists() {
    helm list --kube-context kind-$clustername | grep -w "$RELEASE_NAME" > /dev/null 2>&1
    return $?
}

clusters=$(kind get clusters)

for cluster in $clusters; do
  # Extract the last character of the cluster name as the cluster ID
  cluster_id=${cluster: -1}

  RELEASE_NAME=external-dns-$cluster_id
  if release_exists; then
    echo "Helm release '$RELEASE_NAME' is installed. Removing."
    helm uninstall --kube-context kind-$clustername $RELEASE_NAME
  else
    echo "Helm release '$RELEASE_NAME' is not installed."
  fi
done


RELEASE_NAME=coredns
if release_exists; then
  echo "Helm release '$RELEASE_NAME' is installed. Removing."
  helm uninstall --kube-context kind-$clustername $RELEASE_NAME
else
  echo "Helm release '$RELEASE_NAME' is not installed."
fi


kubectl delete -k base/ --context kind-$clustername
