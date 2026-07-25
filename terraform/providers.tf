terraform {
  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = "~> 0.85" # check registry.terraform.io/providers/bpg/proxmox for the current version
    }
  }
}

provider "proxmox" {
  # Your Proxmox host's web UI address, without the :8006 port suffix issue -
  # bpg's provider wants the full URL including port and /api2/json is NOT needed here.
  endpoint = "https://<HOST_A_IP>:8006"

  api_token = "<TOKEN_ID>=<SECRET>" # e.g. "root@pam!terraform=xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"

  # Proxmox's default cert is self-signed in a homelab - set true to skip verification.
  # Revisit this later if you set up a real cert; leaving it insecure is a known tradeoff for now.
  insecure = true
}
