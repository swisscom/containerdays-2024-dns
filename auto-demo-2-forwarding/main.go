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
	r := demo.NewRun("Demo DNS forwarding by CoreDNS")

	r.Step(demo.S("List yamls in directory"), demo.S("ls | grep .yaml"))
	r.Step(demo.S("Show svc.yaml content"), demo.S("cat svc.yaml"))
	r.StepCanFail(demo.S("Lookup nginx.5gc.3gppnetwork.org using default node DNS"), demo.S("kubectl --context kind-dns-0 exec -t dnsutils -- nslookup nginx.5gc.3gppnetwork.org"))
	r.Step(demo.S("Apply svc.yaml"), demo.S("kubectl --context kind-dns-0 apply -f svc.yaml"))
	r.Step(demo.S("Lookup nginx.5gc.3gppnetwork.org using default node DNS"), demo.S("kubectl --context kind-dns-0 exec -t dnsutils -- nslookup nginx.5gc.3gppnetwork.org"))
	r.Step(demo.S("Show dns-endpoint-cr.yaml content"), demo.S("cat dns-endpoint-cr.yaml"))
	r.Step(demo.S("Apply dns-endpoint-cr.yaml"), demo.S("kubectl --context kind-dns-0 apply -f dns-endpoint-cr.yaml"))
	r.Step(demo.S("Lookup endpoint1.5gc.3gppnetwork.org using default node DNS"), demo.S("kubectl --context kind-dns-0 exec -t dnsutils -- nslookup endpoint1.5gc.3gppnetwork.org"))
	return r
}

func cleanup(ctx *cli.Context) error {
	return demo.Ensure("echo 'demo teardown'")
}
