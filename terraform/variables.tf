variable "subscription_id" {
  type      = string
  sensitive = true
}
variable "location" {
  type    = string
  default = "eastus"
}
variable "project_name" {
  type    = string
  default = "hybridlab"
}
variable "environment" {
  type    = string
  default = "lab"
}
variable "vnet_cidr" {
  type    = string
  default = "10.100.0.0/16"
}
variable "web_subnet_cidr" {
  type    = string
  default = "10.100.2.0/24"
}
variable "admin_cidr" {
  type        = string
  description = "Administrative public CIDR."
}
variable "ssh_public_key" {
  type        = string
  description = "SSH public key for the web VM."
}
variable "web_vm_size" {
  type    = string
  default = "Standard_B1s"
}

variable "storage_account_name" {
  type    = string
  default = "anthomelabsa1"
}
variable "key_vault_name" {
  type    = string
  default = "anthomelabkv1"

}
