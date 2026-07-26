#!/bin/bash
set -euxo pipefail

# Run this once on every new Proxmox physical host, right after the initial
# Proxmox install and before joining it to the cluster.
# Usage: sudo ./proxmox-node-setup.sh

echo "----Disabling Proxmox enterprise repos (require paid subscription)----"
for repo_file in /etc/apt/sources.list.d/pve-enterprise.sources /etc/apt/sources.list.d/ceph.sources; do
  if [ -f "$repo_file" ] && ! grep -q "^Enabled: false" "$repo_file"; then
    echo "Enabled: false" >> "$repo_file"
    echo "Disabled: $repo_file"
  fi
done

echo "----Adding free no-subscription repo----"
echo "deb http://download.proxmox.com/debian/pve trixie pve-no-subscription" \
  > /etc/apt/sources.list.d/pve-no-subscription.list

apt-get update

echo "----Installing Tailscale----"
curl -fsSL https://tailscale.com/install.sh | sh

echo "--- Setup Complete ---"
echo "Run 'tailscale up --authkey=<your-key> --ssh' next to join the tailnet."
echo "(Auth key intentionally not automated here - keep it out of shell history/scripts.)"