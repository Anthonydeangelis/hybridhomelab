variable "subscription_id" {
  type        = string
  description = "Azure subscription used for the standalone web workload."
  sensitive   = true
}
variable "location" {
  type        = string
  description = "Azure region for all resources."
  default     = "eastus"
}
variable "project_name" {
  type        = string
  description = "Short name used in resource names and tags."
  default     = "hybridlab"
}
variable "environment" {
  type        = string
  description = "Environment label used in resource names and tags."
  default     = "lab"
}
variable "vnet_cidr" {
  type        = string
  description = "Address space for the standalone Azure VNet."
  default     = "10.100.0.0/16"
}
variable "web_subnet_cidr" {
  type        = string
  description = "Address space for the web VM subnet."
  default     = "10.100.2.0/24"
}
variable "admin_cidr" {
  type        = string
  description = "Administrative public CIDR."

  validation {
    condition     = can(cidrhost(var.admin_cidr, 0))
    error_message = "admin_cidr must be a valid CIDR, such as 203.0.113.8/32."
  }
}
variable "ssh_public_key" {
  type        = string
  description = "SSH public key for the web VM."
}
variable "web_vm_size" {
  type        = string
  description = "Azure VM size for the public web server."
  default     = "Standard_B1s"
}

variable "storage_account_name" {
  type        = string
  description = "Globally unique Storage Account name."
}
variable "key_vault_name" {
  type        = string
  description = "Globally unique Key Vault name."
}
variable "web_dns_label" {
  type        = string
  description = "Globally unique DNS label for the web VM's public IP."
}
