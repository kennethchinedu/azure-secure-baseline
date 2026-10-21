output "storage_account_id" {
  description = "Resource ID of the storage account"
  value       = azurerm_storage_account.this.id
}

output "storage_account_name" {
  description = "Storage account name, for backend configuration"
  value       = azurerm_storage_account.this.name
}

output "container_name" {
  description = "Container holding the state files"
  value       = azurerm_storage_container.this.name
}
