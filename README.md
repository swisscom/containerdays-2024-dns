# containerdays-2024-dns
Resources used for the ContainerDays 2024 Talk «Building and Operating a Highly Reliable Cloud Native DNS Service With Open Source Technologies»

## Authors

Please feel free to approach us with feedback and questions!

Hoang Anh Mai <hoanganh.mai@swisscom.com>
Fabian Schulz <fabian.schulz1@swisscom.com>
Joel Studler <joel.studler@swisscom.com>

Contact us on slack:

- <https://cloud-native.slack.com>
- <https://kubernetes.slack.com>

## Getting started

For docker engine / virtualization we use [colima](https://github.com/abiosoft/colima) but any other tool for docker such as docker desktop should also work. 

## Prerequisites

- colima:
  - brew install colima
  - colima start dns1 -c 4 -m 4 --network-address
  - colima ssh -p dns1 # ssh onto colima node
    - edit /etc/sysctl.conf and add:
      - fs.inotify.max_user_watches = 1048576
      - fs.inotify.max_user_instances = 512
    - sudo sysctl fs.inotify.max_user_watches=524288
    - sudo sysctl fs.inotify.max_user_instances=512
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
