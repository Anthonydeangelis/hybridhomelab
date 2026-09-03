variable "resource_group_name" {
  type = string
}
variable "location" {
  type = string
}
variable "project_name" {
  type = string
}
variable "environment" {
  type = string
}
variable "admin_cidr" {
  type = string
}
variable "storage_account_name" {
  type = string
}
variable "key_vault_name" {
  type = string
}
variable "tags" {
  type = map(string)
}

data "azurerm_client_config" "current" {}

resource "azurerm_network_security_group" "web" {
  name                = "nsg-${var.project_name}-web"
  resource_group_name = var.resource_group_name
  location            = var.location
  tags                = var.tags
  security_rule {
    name                       = "Allow-SSH-From-Admin-CIDR"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = var.admin_cidr
    destination_address_prefix = "*"

  }
  security_rule {
    name                       = "Allow-HTTP"
    priority                   = 110
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "*"

  }
  security_rule {
    name                       = "Allow-HTTPS"
    priority                   = 120
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "*"
    destination_address_prefix = "*"

  }
}

resource "azurerm_storage_account" "lab" {
  name                            = var.storage_account_name
  resource_group_name             = var.resource_group_name
  location                        = var.location
  account_tier                    = "Standard"
  account_replication_type        = "LRS"
  min_tls_version                 = "TLS1_2"
  allow_nested_items_to_be_public = false
  tags                            = var.tags
}

resource "azurerm_key_vault" "lab" {
  name                       = var.key_vault_name
  location                   = var.location
  resource_group_name        = var.resource_group_name
  tenant_id                  = data.azurerm_client_config.current.tenant_id
  sku_name                   = "standard"
  soft_delete_retention_days = 7
  purge_protection_enabled   = false
  enable_rbac_authorization  = true
  tags                       = var.tags
}

output "web_nsg_id" {
  value = azurerm_network_security_group.web.id
}
output "storage_account_name" {
  value = azurerm_storage_account.lab.name
}
output "key_vault_uri" {
  value = azurerm_key_vault.lab.vault_uri
}

output "key_vault_id" {
  description = "Resource ID of the Key Vault used for VM role assignments."
  value       = azurerm_key_vault.lab.id
}
