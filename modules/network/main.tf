resource "azurerm_virtual_network" "this" {
  name                = var.name
  location            = var.location
  resource_group_name = var.resource_group_name
  address_space       = var.address_space

  tags = var.tags
}

resource "azurerm_subnet" "this" {
  for_each = var.subnets

  name                 = each.value.name
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.this.name
  address_prefixes     = each.value.address_prefixes

  # false = private subnet: no internet egress unless a NAT gateway is added on purpose.
  default_outbound_access_enabled = each.value.default_outbound_access_enabled

  # "Enabled" makes NSG rules apply to private endpoints in this subnet.
  private_endpoint_network_policies = each.value.private_endpoint_network_policies
}

# Created without inline rules. Rules are separate azurerm_network_security_rule resources in the
# calling stack: never add inline security_rule blocks here too, or each apply overwrites the other.
resource "azurerm_network_security_group" "this" {
  for_each = var.subnets

  name                = each.value.nsg_name
  location            = var.location
  resource_group_name = var.resource_group_name

  tags = var.tags
}

resource "azurerm_subnet_network_security_group_association" "this" {
  for_each = var.subnets

  subnet_id                 = azurerm_subnet.this[each.key].id
  network_security_group_id = azurerm_network_security_group.this[each.key].id
}
