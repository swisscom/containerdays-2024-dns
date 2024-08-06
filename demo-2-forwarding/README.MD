# Demo 2: Forwarding

## Setup from before:

kubectl --context kind-dns-0 get pods -n dns

kubectl --context kind-dns-0 describe cm/coredns -n dns

kubectl --context kind-dns-0 get pods -n dns -o wide

kubectl --context kind-dns-0 exec -it dnsutils -- dig nginx.5gc.3gppnetwork.org 10.244.0.8

## For preparing the next demo whilest going through the slides execute:
./demo-2-forwarding/prepare-demo3.sh
