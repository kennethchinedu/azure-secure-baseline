# Private DNS for private endpoints: one zone per service, shared by every endpoint of that service.
# Azure inserts <vault>.privatelink.vaultcore.azure.net into the vault's public CNAME chain; inside a
# linked VNet this zone answers that name with the endpoint's private IP. Outside, it resolves publicly.
resource "azurerm_private_dns_zone" "key_vault" {
  name                = "privatelink.vaultcore.azure.net" # exact name; not privatelink.vault.azure.net
  resource_group_name = azurerm_resource_group.app.name

  tags = local.tags
}

# Only VNets linked to the zone see it. Peered VNets need their own link.
resource "azurerm_private_dns_zone_virtual_network_link" "key_vault" {
  name                  = "link-vnet-app-${local.name_suffix}"
  resource_group_name   = azurerm_resource_group.app.name
  private_dns_zone_name = azurerm_private_dns_zone.key_vault.name
  virtual_network_id    = module.network.vnet_id
  registration_enabled  = false # auto-registration is for VM hostnames, not endpoints

  tags = local.tags
}
