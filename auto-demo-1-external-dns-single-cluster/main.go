package main

import (
	"github.com/saschagrunert/demo"
	"github.com/urfave/cli/v2"
)

func main() {
	d := demo.New()

	d.Name = "Multicluster DNS Demo"

	d.Setup(setupEnv)
	d.Cleanup(cleanup)

	d.Add(demo1(), "dns-demo-1", "ExternalDNS & PowerDNS")

	d.Run()
}

func demo1() *demo.Run {
	r := demo.NewRun("Apply SVC and DNSEndpoint and let ExternalDNS sync to PowerDNS")

	r.Step(demo.S("Get all pods from kind cluster"), demo.S("kubectl get pods --all-namespaces"))
	r.Step(demo.S("Show service yaml"), demo.S("cat svc.yaml"))
	r.Step(demo.S("Apply svc.yaml"), demo.S("kubectl --context kind-dns-0 apply -f svc.yaml"))
	r.Step(demo.S("Get ExternalDNS logs"), demo.S("kubectl --context kind-dns-0 -n dns logs deploy/external-dns-0 --tail 5"))
	r.Step(demo.S("Check that entry is in PowerDNS"), demo.S("kubectl --context kind-dns-1 exec -it dnsutils -- dig +noall +answer nginx.5gc.3gppnetwork.org 10.96.0.12"))
	return r
}

func setupEnv(ctx *cli.Context) error {
	return demo.Ensure(
		"echo 'demo setup'",
	)
}

func cleanup(ctx *cli.Context) error {
	return demo.Ensure("echo 'demo teardown'")
}
