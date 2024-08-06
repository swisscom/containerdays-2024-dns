# Demo 1: ExternalDNS & PowerDNS Single Cluster

## Setup:

./create-kind-clusters.sh 1
./setup-kind.sh 0

kubectl get svc -n dns -o wide | grep pdns-service

kubectl --context kind-dns-0 exec -it dnsutils -- dig nginx.5gc.3gppnetwork.org 10.96.0.12

kubectl --context kind-dns-0 apply -f some-svc.yaml

kubectl get nodes -o wide

kubectl --context kind-dns-0 -n dns logs deploy/external-dns-0 --tail 5

kubectl --context kind-dns-0 exec -it dnsutils -- dig nginx.5gc.3gppnetwork.org 10.96.0.12

kubectl --context kind-dns-0 apply -f some-dns-endpoint-cr-1.yaml
