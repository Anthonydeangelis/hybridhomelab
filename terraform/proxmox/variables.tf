variable "proxmox_endpoint" {
  type        = string
  description = "Proxmox API endpoint, for example https://192.168.1.50:8006/api2/json."
}

variable "proxmox_api_token" {
  type        = string
  description = "Proxmox API token in user@realm!token=secret form."
  sensitive   = true
}

variable "proxmox_insecure" {
  type        = bool
  description = "Set true only when using Proxmox's self-signed certificate."
  default     = true
}

variable "node_name" {
  type        = string
  description = "Target Proxmox node name, for example pve."
}

variable "datastore_id" {
  type        = string
  description = "Target datastore, commonly local-lvm."
}

variable "bridge" {
  type        = string
  description = "Proxmox network bridge, commonly vmbr0."
  default     = "vmbr0"
}

variable "windows_template_id" {
  type        = number
  description = "VM ID of the Sysprepped Windows Server template."
}

variable "ubuntu_template_id" {
  type        = number
  description = "VM ID of the Ubuntu Cloud-Init template."
}

variable "linux_username" {
  type        = string
  description = "Initial Linux administrator account for Ubuntu clones."
  default     = "labadmin"
}

variable "ssh_public_key" {
  type        = string
  description = "Public SSH key installed in Ubuntu clones."
}

variable "fs01_vmid" {
  type        = number
  description = "Available VM ID to assign to FS01."
}

variable "ubuntu_servers" {
  description = "Ubuntu VMs created from the Ubuntu Cloud-Init template."
  type = map(object({
    vmid      = number
    cores     = number
    memory_mb = number
    disk_gb   = number
    address   = string
  }))
}
variable "tailscalebox" {
  description = "tailscale VM"
  type = map(object({
    vmid      = number
    cores     = number
    memory_mb = number
    disk_gb   = number
    address   = string
    gateway   = string
  }))
}