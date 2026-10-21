output "vnet_id" {
  description = "Resource ID of the VNet"
  value       = azurerm_virtual_network.this.id
}

output "vnet_name" {
  description = "VNet name"
  value       = azurerm_virtual_network.this.name
}

output "subnet_ids" {
  description = "Subnet IDs by role key"
  value       = { for k, s in azurerm_subnet.this : k => s.id }
}

output "subnet_address_prefixes" {
  description = "Subnet address prefixes by role key"
  value       = { for k, s in azurerm_subnet.this : k => s.address_prefixes }
}

output "nsg_ids" {
  description = "NSG IDs by subnet role key"
  value       = { for k, n in azurerm_network_security_group.this : k => n.id }
}

output "nsg_names" {
  description = "NSG names by subnet role key, for azurerm_network_security_rule"
  value       = { for k, n in azurerm_network_security_group.this : k => n.name }
}
