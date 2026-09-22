# Module 00 — the VM: back to zero

## Foreword

Every module ends the same way: you destroy the machine and replay the whole thing from nothing.
If that reset is not trustworthy, every module after this one is debugging a ghost. So the first
layer of the lab is the machine itself, and the first fault is a reset that did not reset.

No k3s here. That is module 01.

## Objectives

- Create and destroy a disposable VM from a single command.
- Tell a fresh machine from one that only looks fresh.
- Read `multipass` state instead of trusting that a command did what its name says.

## Instructions

The VM is `labk3s-00`: Ubuntu 26.04, 2 vCPU, 2 GB, 10 GB. The name is fixed on purpose.

The loop for this module, and for every module after it:

```
make up → make check → make incident → observe → hypothesis → test → repair → make check → make reset
```

Do not open the solution before `make check` has gone green by your own hand. Write down what
you saw, what you guessed, and the one command that confirmed it. That habit is the whole lab.

## Mandatory part

```sh
make up MODULE=00
make check MODULE=00      # must exit 0
make incident MODULE=00
make check MODULE=00      # must exit non-zero
```

Now repair it. `make check` must exit 0 again, on a machine that carries nothing from before.

Read the exit code, not the output. `make check | grep GREEN` succeeds on a red check.

You are done when you can replay the module from zero without reading this page.

### What `make check` verifies

1. the instance exists
2. it is `Running`
3. it answers `multipass exec`
4. it carries the generation stamp the host recorded at `make up`
5. it carries no work left over from a previous run
6. no `labk3s-*` instance is sitting in state `Deleted`

Check 5 and 6 are the ones that will catch you.

## Bonus

- Make `make reset` finish in under 40 s on your host, and say where the time goes.
- `make clean` must leave nothing behind. Prove it, including disk usage.
- Break check 6 without running `make incident`.

<details>
<summary>Solution</summary>

`make incident` writes a file inside the VM, then runs `multipass delete labk3s-00` — **without
`--purge`**. `multipass list` shows the instance in state `Deleted`. It is not gone: the name is
still taken, and `multipass launch` on that name fails with `instance "labk3s-00" already exists`
and exit code 2.

The obvious move is `multipass recover labk3s-00`, then `multipass start labk3s-00`. The instance
comes back `Running` and looks brand new. It is not: `/var/lib/lab-k3s/leftover` is still there,
because recover restores the disk as it was. Check 5 catches it. A reset that recovers is not a
reset — it is an undo.

The repair:

```sh
multipass delete --purge labk3s-00   # or: multipass purge, after a plain delete
make up MODULE=00
make check MODULE=00
```

`make clean` does exactly this. `make reset` is `clean` then `up`.

The lesson generalises past multipass: `delete` marked it, `purge` freed it, and in between the
system reported a state that was neither gone nor healthy. You will meet that gap again in module
11, where a restore gives you back a cluster that lies.

</details>
