output "resource_group_name" {
  description = "Application resource group"
  value       = azurerm_resource_group.app.name
}

output "vnet_id" {
  description = "Application VNet ID"
  value       = module.network.vnet_id
}

output "subnet_ids" {
  description = "Subnet IDs by role (app, pe)"
  value       = module.network.subnet_ids
}

output "nsg_ids" {
  description = "NSG IDs by subnet role"
  value       = module.network.nsg_ids
}

output "key_vault_id" {
  value = module.key_vault.id
}

output "key_vault_name" {
  value = module.key_vault.name
}

output "key_vault_uri" {
  value = module.key_vault.vault_uri
}

output "key_vault_officers_group" {
  description = "Entra group whose members can manage secrets"
  value       = azuread_group.kv_secrets_officers.display_name
}
