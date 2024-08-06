# Demo 3 Multi-cluster DNS

kubectl --context kind-dns-0 apply -f some-dns-endpoint-cr-1.yaml

kubectl --context kind-dns-0 exec -it dnsutils -- nslookup endpoint1.5gc.3gppnetwork.org

kubectl --context kind-dns-1 exec -it dnsutils -- nslookup endpoint1.5gc.3gppnetwork.org

kubectl --context kind-dns-2 exec -it dnsutils -- nslookup endpoint1.5gc.3gppnetwork.org

kubectl --context kind-dns-2 apply -f some-dns-endpoint-cr-2.yaml

kubectl --context kind-dns-0 exec -it dnsutils -- nslookup endpoint2.5gc.3gppnetwork.org

kubectl --context kind-dns-1 exec -it dnsutils -- nslookup endpoint2.5gc.3gppnetwork.org

kubectl --context kind-dns-2 exec -it dnsutils -- nslookup endpoint2.5gc.3gppnetwork.org

kubectl --context kind-dns-0 -n dns scale deployment pdns-deployment --replicas=0

kubectl --context kind-dns-0 apply -f some-dns-endpoint-cr-3.yaml

kubectl --context kind-dns-0 exec -it dnsutils -- nslookup endpoint3.5gc.3gppnetwork.org

kubectl --context kind-dns-0 -n dns scale deployment pdns-deployment --replicas=1
