provider "proxmox" {
  endpoint  = var.proxmox_endpoint
  api_token = var.proxmox_api_token
  insecure  = var.proxmox_insecure

  # The provider can require SSH access to the Proxmox host for some operations.
  # Use your local ssh-agent rather than storing a private key in this repository.
  ssh {
    agent = true
  }
}
