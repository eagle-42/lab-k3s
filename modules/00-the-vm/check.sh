#!/usr/bin/env bash
# Tell whether this VM is running, reachable, and the very one the last `make up` created.
set -uo pipefail

: "${VM:?}" "${STATE:?}"

red() {
	echo "check: RED - $*" >&2
	exit 1
}

state=$(multipass list --format csv | awk -F, -v n="$VM" 'NR>1 && $1==n {print $2}')
[ -n "$state" ] || red "$VM does not exist, run 'make up'"
[ "$state" = "Running" ] || red "$VM is in state '$state', expected Running"

multipass exec "$VM" -- true 2>/dev/null || red "$VM does not answer 'multipass exec'"

expected=$(cat "$STATE/$VM.generation" 2>/dev/null)
[ -n "$expected" ] || red "the host has no generation for $VM, run 'make up'"

actual=$(multipass exec "$VM" -- cat /var/lib/lab-k3s/generation 2>/dev/null | tr -d '\r')
[ -n "$actual" ] || red "$VM carries no generation stamp"
[ "$actual" = "$expected" ] || red "$VM carries generation '$actual' but the host expects '$expected'"

multipass exec "$VM" -- test ! -e /var/lib/lab-k3s/leftover 2>/dev/null ||
	red "$VM still carries work from a previous run, it did not come back from zero"

stale=$(multipass list --format csv | awk -F, 'NR>1 && $1 ~ /^labk3s-/ && $2=="Deleted" {print $1}')
[ -z "$stale" ] || red "deleted but not purged: $(echo "$stale" | tr '\n' ' ')- the name is still taken"

echo "check: GREEN - $VM is running, reachable, generation $actual"
