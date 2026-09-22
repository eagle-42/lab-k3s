#!/usr/bin/env bash
# Break module 00: leave work inside the VM, then delete it the way that looks like a reset.
set -euo pipefail

: "${VM:?}"

multipass exec "$VM" -- sudo mkdir -p /var/lib/lab-k3s
printf 'an afternoon of work\n' | multipass exec "$VM" -- sudo tee /var/lib/lab-k3s/leftover >/dev/null

multipass delete "$VM"

echo "incident: done. Run 'make check'."
