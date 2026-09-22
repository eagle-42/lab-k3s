#!/usr/bin/env bash
# Create the module 00 VM and stamp it with a generation id.
set -euo pipefail

: "${VM:?}" "${IMAGE:?}" "${CPUS:?}" "${MEM:?}" "${DISK:?}" "${STATE:?}"

state=$(multipass list --format csv | awk -F, -v n="$VM" 'NR>1 && $1==n {print $2}')
if [ "$state" = "Running" ]; then
	echo "up: $VM is already running"
	exit 0
fi

multipass launch "$IMAGE" --name "$VM" --cpus "$CPUS" --memory "$MEM" --disk "$DISK"

generation="$(date -u +%s)-$$"
multipass exec "$VM" -- sudo mkdir -p /var/lib/lab-k3s
printf '%s\n' "$generation" | multipass exec "$VM" -- sudo tee /var/lib/lab-k3s/generation >/dev/null

mkdir -p "$STATE"
printf '%s\n' "$generation" >"$STATE/$VM.generation"

echo "up: $VM is running, generation $generation"
