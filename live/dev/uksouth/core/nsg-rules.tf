# Default-deny network: each subnet reaches only what its role needs.
#   app -> pe on TCP 443 (Key Vault private endpoint); nothing else in the VNet, no internet.
#   pe  <- app on TCP 443 only.
# Azure's defaults allow everything inside the VNet (AllowVnetInBound/OutBound at 65000),

# ---------- nsg-app (snet-app) ----------

resource "azurerm_network_security_rule" "app_allow_pe_https_outbound" {
  name                         = "allow-pe-https-outbound"
  resource_group_name          = azurerm_resource_group.app.name
  network_security_group_name  = module.network.nsg_names["app"]
  priority                     = 100
  direction                    = "Outbound"
  access                       = "Allow"
  protocol                     = "Tcp"
  source_port_range            = "*"
  destination_port_range       = "443"
  source_address_prefixes      = local.subnet_cidrs.app
  destination_address_prefixes = local.subnet_cidrs.pe
}

resource "azurerm_network_security_rule" "app_deny_internet_outbound" {
  name                        = "deny-internet-outbound"
  resource_group_name         = azurerm_resource_group.app.name
  network_security_group_name = module.network.nsg_names["app"]
  priority                    = 4000
  direction                   = "Outbound"
  access                      = "Deny"
  protocol                    = "*"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = "*"
  destination_address_prefix  = "Internet"
}

resource "azurerm_network_security_rule" "app_deny_vnet_outbound" {
  name                        = "deny-vnet-outbound"
  resource_group_name         = azurerm_resource_group.app.name
  network_security_group_name = module.network.nsg_names["app"]
  priority                    = 4001
  direction                   = "Outbound"
  access                      = "Deny"
  protocol                    = "*"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = "VirtualNetwork"
  destination_address_prefix  = "VirtualNetwork"
}

resource "azurerm_network_security_rule" "app_deny_internet_inbound" {
  name                        = "deny-internet-inbound"
  resource_group_name         = azurerm_resource_group.app.name
  network_security_group_name = module.network.nsg_names["app"]
  priority                    = 4000
  direction                   = "Inbound"
  access                      = "Deny"
  protocol                    = "*"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = "Internet"
  destination_address_prefix  = "*"
}

# ---------- nsg-pe (snet-pe) ----------

resource "azurerm_network_security_rule" "pe_allow_app_https_inbound" {
  name                        = "allow-app-https-inbound"
  resource_group_name         = azurerm_resource_group.app.name
  network_security_group_name = module.network.nsg_names["pe"]
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "443"
  source_address_prefixes     = local.subnet_cidrs.app
  destination_address_prefix  = "*"
}

resource "azurerm_network_security_rule" "pe_deny_vnet_inbound" {
  name                        = "deny-vnet-inbound"
  resource_group_name         = azurerm_resource_group.app.name
  network_security_group_name = module.network.nsg_names["pe"]
  priority                    = 4000
  direction                   = "Inbound"
  access                      = "Deny"
  protocol                    = "*"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = "VirtualNetwork"
  destination_address_prefix  = "*"
}
