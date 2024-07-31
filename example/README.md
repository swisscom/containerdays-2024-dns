# Examples

## Simple Service with ExternalDNS Annotation

```bash
kubectl --context kind-dns-0 apply -f example/some-svc.yaml
kubectl --context kind-dns-0 exec -it dnsutils -- dig nginx.5gc.3gppnetwork.org
kubectl --context kind-dns-1 exec -it dnsutils -- dig nginx.5gc.3gppnetwork.org
```

## DNSRecord with NAPTR entry

```bash
kubectl --context kind-dns-0 apply -f example/some-naptr-dnsrecord.yaml
kubectl --context kind-dns-0 exec -it dnsutils -- dig naptrentry.5gc.3gppnetwork.org
kubectl --context kind-dns-1 exec -it dnsutils -- dig naptrentry.5gc.3gppnetwork.org
```
