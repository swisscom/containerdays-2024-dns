package main

import (
	"github.com/saschagrunert/demo"
	"github.com/urfave/cli/v2"
)

func main() {
	d := demo.New()

	d.Name = "Multicluster DNS Demo"

	d.Cleanup(cleanup)

	d.Add(demo1(), "dns-demo-2", "Forwarding")

	d.Run()
}

func demo1() *demo.Run {
	r := demo.NewRun("Demo DNS multi-cluster")

	r.Step(nil, demo.S("ls | grep .yaml"))
	r.Step(demo.S("Show dns-endpoint-cr-1.yaml content"), demo.S("cat dns-endpoint-cr-1.yaml"))
	r.Step(demo.S("Apply dns-endpoint-cr-1.yaml to cluster 0"), demo.S("kubectl --context kind-dns-0 apply -f dns-endpoint-cr-1.yaml"))
	r.Step(demo.S("Lookup endpoint1.5gc.3gppnetwork.org using default node DNS in cluster 0"), demo.S("kubectl --context kind-dns-0 exec -t dnsutils -- nslookup endpoint1.5gc.3gppnetwork.org"))
	r.Step(demo.S("Lookup endpoint1.5gc.3gppnetwork.org using default node DNS in cluster 1"), demo.S("kubectl --context kind-dns-1 exec -t dnsutils -- nslookup endpoint1.5gc.3gppnetwork.org"))
	r.Step(demo.S("Apply dns-endpoint-cr-2.yaml to cluster 1"), demo.S("kubectl --context kind-dns-1 apply -f dns-endpoint-cr-2.yaml"))
	r.Step(demo.S("Lookup endpoint2.5gc.3gppnetwork.org using default node DNS in cluster 0"), demo.S("kubectl --context kind-dns-0 exec -t dnsutils -- nslookup endpoint2.5gc.3gppnetwork.org"))
	r.Step(demo.S("Scale down PowerDNS deployment in cluster 0"), demo.S("kubectl --context kind-dns-0 -n dns scale deployment pdns-deployment --replicas=0"))
	r.Step(demo.S("Lookup endpoint2.5gc.3gppnetwork.org using default node DNS in cluster 0"), demo.S("kubectl --context kind-dns-0 exec -t dnsutils -- nslookup endpoint2.5gc.3gppnetwork.org"))
	r.Step(demo.S("Apply dns-endpoint-cr-3.yaml to cluster 0"), demo.S("kubectl --context kind-dns-0 apply -f dns-endpoint-cr-3.yaml"))
	r.Step(demo.S("Lookup endpoint3.5gc.3gppnetwork.org using default node DNS in cluster 1"), demo.S("kubectl --context kind-dns-1 exec -t dnsutils -- nslookup endpoint3.5gc.3gppnetwork.org"))
	r.Step(demo.S("Lookup endpoint3.5gc.3gppnetwork.org using default node DNS in cluster 0"), demo.S("kubectl --context kind-dns-0 exec -t dnsutils -- nslookup endpoint3.5gc.3gppnetwork.org"))
	r.Step(demo.S("Scale down CoreDNS deployment in cluster 0"), demo.S("kubectl --context kind-dns-0 -n dns scale deployment coredns --replicas=0"))
	r.StepCanFail(demo.S("Lookup endpoint3.5gc.3gppnetwork.org using default node DNS in cluster 0"), demo.S("kubectl --context kind-dns-0 exec -t dnsutils -- nslookup endpoint3.5gc.3gppnetwork.org"))
	r.Step(demo.S("Lookup google.com using default node DNS in cluster 0"), demo.S("kubectl --context kind-dns-0 exec -it dnsutils -- nslookup google.com"))
	return r
}

func cleanup(ctx *cli.Context) error {
	return demo.Ensure("echo 'demo teardown'")
}
