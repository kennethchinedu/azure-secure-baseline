# Workload VM: proves the private path. Its managed identity reads a secret through the vault's private
# endpoint, with no public IP, no internet egress and no stored credential. Reached with az vm run-command.
module "workload_vm" {
  source = "../../../../modules/linux-vm"

  name                 = "vm-app-${local.name_suffix}"
  resource_group_name  = azurerm_resource_group.app.name
  location             = azurerm_resource_group.app.location
  subnet_id            = module.network.subnet_ids["app"]
  admin_ssh_public_key = var.vm_admin_ssh_public_key

  tags = local.tags
}
