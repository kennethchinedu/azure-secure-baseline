resource "azurerm_resource_group" "app" {
  name     = "rg-app-${local.name_suffix}"
  location = local.location

  tags = local.tags
}

# VNet, subnets and one empty NSG per subnet. The rules are in nsg-rules.tf.
module "network" {
  source = "../../../../modules/network"

  name                = "vnet-app-${local.name_suffix}"
  resource_group_name = azurerm_resource_group.app.name
  location            = azurerm_resource_group.app.location
  address_space       = local.address_space
  tags                = local.tags

  subnets = {
    app = {
      name             = "snet-app"
      address_prefixes = local.subnet_cidrs.app
      nsg_name         = "nsg-app-${local.name_suffix}"
    }

    pe = {
      name             = "snet-pe"
      address_prefixes = local.subnet_cidrs.pe
      nsg_name         = "nsg-pe-${local.name_suffix}"
    }
  }
}
