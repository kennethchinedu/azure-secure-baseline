
output "resource_group_name" {
  description = "Terraform state resource group"
  value       = azurerm_resource_group.tfstate.name
}

output "storage_account_name" {
  description = "Storage account name for the backend configuration"
  value       = azurerm_storage_account.tfstate.name
}

output "storage_account_id" {
  description = "Resource ID of the storage account"
  value       = azurerm_storage_account.tfstate.id
}

output "container_name" {
  description = "Private blob container holding Terraform state"
  value       = azurerm_storage_container.tfstate.name
}

output "tenant_id" {
  description = "Azure tenant ID"
  value       = data.azurerm_client_config.current.tenant_id
}
