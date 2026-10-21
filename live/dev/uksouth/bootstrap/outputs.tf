output "resource_group_name" {
  description = "Terraform state resource group"
  value       = azurerm_resource_group.tfstate.name
}

output "storage_account_name" {
  description = "Storage account name for backend configuration"
  value       = module.state_storage.storage_account_name
}

output "storage_account_id" {
  description = "Resource ID of the storage account"
  value       = module.state_storage.storage_account_id
}

output "container_name" {
  description = "Private blob container holding Terraform state"
  value       = module.state_storage.container_name
}

output "tenant_id" {
  description = "Azure tenant ID"
  value       = data.azurerm_client_config.current.tenant_id
}
