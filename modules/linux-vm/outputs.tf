output "id" {
  description = "VM ID."
  value       = azurerm_linux_virtual_machine.this.id
}

output "name" {
  description = "VM name, for az vm run-command."
  value       = azurerm_linux_virtual_machine.this.name
}

output "principal_id" {
  description = "Object ID of the VM's system-assigned managed identity, for role assignments."
  value       = azurerm_linux_virtual_machine.this.identity[0].principal_id
}

output "private_ip_address" {
  description = "Private IP of the VM's NIC."
  value       = azurerm_network_interface.this.private_ip_address
}
