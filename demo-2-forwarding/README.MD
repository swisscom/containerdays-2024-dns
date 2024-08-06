# Demo 2: Forwarding

```
kubectl --context kind-dns-0 get pods -n dns
```

```
kubectl --context kind-dns-0 describe cm/coredns -n dns
```

```
kubectl --context kind-dns-0 get pods -n dns -o wide
```

```
kubectl --context kind-dns-0 exec -it dnsutils -- nslookup nginx.5gc.3gppnetwork.org
```

```
kubectl --context kind-dns-0 apply -f some-svc.yaml
```

```
kubectl --context kind-dns-0 apply -f some-dns-endpoint-cr-1.yaml
```

```
kubectl --context kind-dns-0 exec -it dnsutils -- nslookup nginx.5gc.3gppnetwork.org
```

```
kubectl --context kind-dns-0 exec -it dnsutils -- nslookup endpoint1.5gc.3gppnetwork.org
```
