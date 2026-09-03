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
variable "vnet_cidr" {
  type = string
}
variable "web_subnet_cidr" {
  type = string
}
variable "tags" {
  type = map(string)
}

resource "azurerm_virtual_network" "lab" {
  name                = "vnet-${var.project_name}-${var.environment}"
  address_space       = [var.vnet_cidr]
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = var.tags
}
resource "azurerm_subnet" "web" {
  name                 = "snet-web"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.lab.name
  address_prefixes     = [var.web_subnet_cidr]
}
resource "azurerm_public_ip" "web" {
  name                = "pip-${var.project_name}-web"
  resource_group_name = var.resource_group_name
  location            = var.location
  allocation_method   = "Static"
  sku                 = "Standard"
  tags                = var.tags
}
output "web_subnet_id" {
  value = azurerm_subnet.web.id
}
output "web_public_ip_id" {
  value = azurerm_public_ip.web.id
}
output "web_public_ip_address" {
  value = azurerm_public_ip.web.ip_address
}
