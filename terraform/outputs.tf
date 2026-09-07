output "resource_group_name" {
  value = azurerm_resource_group.lab.name
}
output "web_public_ip" {
  value = module.networking.web_public_ip_address
}
output "web_public_fqdn" {
  value = module.networking.web_public_fqdn
}
output "web_vm_name" {
  value = module.compute.vm_name
}
output "storage_account_name" {
  value = module.security.storage_account_name
}
output "key_vault_uri" {
  value = module.security.key_vault_uri
}
output "web_vm_principal_id" {
  description = "Object ID of the Azure web VM's system-assigned managed identity."
  value       = module.compute.vm_principal_id
}
