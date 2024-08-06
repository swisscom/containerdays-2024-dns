# Demo 1: ExternalDNS & PowerDNS Single Cluster


```
kubectl get svc -n dns -o wide | grep pdns-service
```


```
kubectl --context kind-dns-0 apply -f some-svc.yaml
```

```
kubectl --context kind-dns-0 -n dns logs deploy/external-dns-0 --tail 5
```

```
kubectl --context kind-dns-0 apply -f some-dns-endpoint-cr-1.yaml
```

```
pdnsutil list-all-zones
```

```
pdnsutil list-zone 5gc.3gppnetwork.org
```
