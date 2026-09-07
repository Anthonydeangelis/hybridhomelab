resource "azurerm_resource_group" "lab" {
  name     = "rg-${var.project_name}-${var.environment}"
  location = var.location
  tags     = local.tags
}

module "networking" {
  source              = "./modules/networking"
  resource_group_name = azurerm_resource_group.lab.name
  location            = azurerm_resource_group.lab.location
  project_name        = var.project_name
  environment         = var.environment
  vnet_cidr           = var.vnet_cidr
  web_subnet_cidr     = var.web_subnet_cidr
  web_dns_label       = var.web_dns_label
  tags                = local.tags
}

module "security" {
  source               = "./modules/security"
  resource_group_name  = azurerm_resource_group.lab.name
  location             = azurerm_resource_group.lab.location
  project_name         = var.project_name
  environment          = var.environment
  admin_cidr           = var.admin_cidr
  storage_account_name = var.storage_account_name
  key_vault_name       = var.key_vault_name
  tags                 = local.tags
}

resource "azurerm_subnet_network_security_group_association" "web" {
  subnet_id                 = module.networking.web_subnet_id
  network_security_group_id = module.security.web_nsg_id
}

module "compute" {
  source              = "./modules/compute"
  resource_group_name = azurerm_resource_group.lab.name
  location            = azurerm_resource_group.lab.location
  project_name        = var.project_name
  environment         = var.environment
  subnet_id           = module.networking.web_subnet_id
  public_ip_id        = module.networking.web_public_ip_id
  ssh_public_key      = var.ssh_public_key
  vm_size             = var.web_vm_size
  tags                = local.tags
}

resource "azurerm_role_assignment" "web_key_vault_secrets_user" {
  scope                            = module.security.key_vault_id
  role_definition_name             = "Key Vault Secrets User"
  principal_id                     = module.compute.vm_principal_id
  principal_type                   = "ServicePrincipal"
  skip_service_principal_aad_check = true
}
