package main

import (
	"github.com/saschagrunert/demo"
	"github.com/urfave/cli/v2"
)

func main() {
	d := demo.New()

	d.Name = "Multicluster DNS Demo"

	d.Cleanup(cleanup)

	d.Add(demo1(), "dns-demo-1", "ExternalDNS & PowerDNS")

	d.Run()
}

func demo1() *demo.Run {
	r := demo.NewRun("Apply SVC and DNSEndpoint and let ExternalDNS sync to PowerDNS")

	r.Step(nil, demo.S("kubectl get pods --all-namespaces"))
	r.Step(nil, demo.S("cat svc.yaml"))
	r.Step(nil, demo.S("kubectl --context kind-dns-0 apply -f svc.yaml"))
	r.Step(nil, demo.S("kubectl --context kind-dns-0 -n dns logs deploy/external-dns-0 --tail 10"))
	r.Step(nil, demo.S("kubectl --context kind-dns-0 exec -t dnsutils -- dig +noall +answer nginx.5gc.3gppnetwork.org pdns-service.dns.svc.cluster.local"))
	return r
}

func cleanup(ctx *cli.Context) error {
	return demo.Ensure("../prepare-demo2-continued.sh")
}
