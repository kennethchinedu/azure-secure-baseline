output "id" {
  description = "Private endpoint ID, for ordering (e.g. before public access is turned off on the target)."
  value       = azurerm_private_endpoint.this.id
}

output "private_ip_address" {
  description = "Private IP address assigned to the private endpoint."
  value       = azurerm_private_endpoint.this.private_service_connection[0].private_ip_address
}
