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
