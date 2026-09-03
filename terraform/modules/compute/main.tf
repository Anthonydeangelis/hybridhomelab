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
variable "subnet_id" {
  type = string
}
variable "public_ip_id" {
  type = string
}
variable "ssh_public_key" {
  type = string
}
variable "vm_size" {
  type = string
}
variable "tags" {
  type = map(string)
}

resource "azurerm_network_interface" "web" {
  name                = "nic-${var.project_name}-web"
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = var.tags
  ip_configuration {
    name                          = "primary"
    subnet_id                     = var.subnet_id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = var.public_ip_id

  }
}

resource "azurerm_linux_virtual_machine" "web" {
  name                            = "web-${var.project_name}-${var.environment}"
  resource_group_name             = var.resource_group_name
  location                        = var.location
  size                            = var.vm_size
  admin_username                  = "azureadmin"
  disable_password_authentication = true
  network_interface_ids           = [azurerm_network_interface.web.id]
  tags                            = var.tags

  identity {
    type = "SystemAssigned"
  }

  admin_ssh_key {
    username   = "azureadmin"
    public_key = var.ssh_public_key

  }
  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"

  }
  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"

  }
}

output "vm_name" {
  value = azurerm_linux_virtual_machine.web.name
}

output "vm_principal_id" {
  description = "Object ID of the VM's system-assigned managed identity."
  value       = azurerm_linux_virtual_machine.web.identity[0].principal_id
}
