# containerdays-2024-dns
Resources used for the ContainerDays 2024 Talk «Building and Operating a Highly Reliable Cloud Native DNS Service With Open Source Technologies»

## Getting started

For docker engine / virtualization we use [colima](https://github.com/abiosoft/colima) but any other tool for docker such as docker desktop should also work. 

## Prerequisites

- colima:
  - brew install colima
  - colima start dns1 -c 4 -m 4 --network-address
- docker cli: brew install docker
- kind: brew install kind

## Environment setup

To create 3 kind clusters execute:
./create-kind-clusters.sh 3

The clusters will be named dns-0, dns-1, dns-2.

The setup script accepts the cluster id and an optional clusternameprefix parameter, so call it for each cluster like that:
- ./setup-kind.sh 0
- ./setup-kind.sh 1
- ./setup-kind.sh 2

## Environment teardown

To teardown the kind clusters simply execute:
./destroy-kind.sh 3
