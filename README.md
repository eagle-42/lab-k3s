# lab-k3s

K3s from scratch, one layer at a time. Each module builds a layer, breaks it on purpose, and
leaves you to diagnose it. Learn-by-breaking, 42-style subjects.

## Modules

| | | |
|---|---|---|
| **A. the cluster exists** | 00 the VM · 01 bootstrap · 02 a second node | |
| **B. a workload runs** | 03 control plane · 04 workloads · 05 scheduling | |
| **C. the network** | 06 pod network · 07 services · 08 ingress | |
| **D. what survives** | 09 volumes · 10 upgrade and drain · 11 backup and restore | |
| **E. security** | 12 RBAC · 13 what gets refused · 14 hardening the container | |

## Run it

```sh
make up MODULE=00      # create the VM, build the layer
make check MODULE=00   # green or red
make incident MODULE=00
make reset MODULE=00   # back to zero, 40 s
make clean MODULE=00
```

`make` alone lists the targets and the modules.

## Requirements

Linux host with [multipass](https://multipass.run), ~4 GB free, UDP 8472 open between VMs.
Needs network: the images and the k3s installer are downloaded. There is no offline mode.
