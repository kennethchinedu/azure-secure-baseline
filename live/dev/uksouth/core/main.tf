resource "azurerm_resource_group" "app" {
  name     = "rg-app-uks-dev"
  location = "UK South"

  tags = local.tags
}

resource "azurerm_virtual_network" "app" {
  name                = "vnet-app-uks-dev"
  location            = azurerm_resource_group.app.location
  resource_group_name = azurerm_resource_group.app.name
  address_space       = ["10.30.0.0/16"]

  tags = local.tags
}

resource "azurerm_subnet" "app" {
  name                            = "snet-app"
  resource_group_name             = azurerm_resource_group.app.name
  virtual_network_name            = azurerm_virtual_network.app.name
  address_prefixes                = ["10.30.1.0/24"]
  default_outbound_access_enabled = false
}

resource "azurerm_subnet" "pe" {
  name                            = "snet-pe"
  resource_group_name             = azurerm_resource_group.app.name
  virtual_network_name            = azurerm_virtual_network.app.name
  address_prefixes                = ["10.30.2.0/24"]
  default_outbound_access_enabled = false
}


resource "azurerm_network_security_group" "app" {
  name                = "nsg-app-uks-dev"
  location            = azurerm_resource_group.app.location
  resource_group_name = azurerm_resource_group.app.name

  security_rule {
    name                       = "deny-internet-inbound"
    priority                   = 4000
    direction                  = "Inbound"
    access                     = "Deny"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "Internet"
    destination_address_prefix = "*"
  }

  security_rule {
    name                         = "allow-pe-https-outbound"
    priority                     = 100
    direction                    = "Outbound"
    access                       = "Allow"
    protocol                     = "Tcp"
    source_port_range            = "*"
    destination_port_range       = "443"
    source_address_prefixes      = azurerm_subnet.app.address_prefixes
    destination_address_prefixes = azurerm_subnet.pe.address_prefixes
  }

  security_rule {
    name                       = "deny-internet-outbound"
    priority                   = 4000
    direction                  = "Outbound"
    access                     = "Deny"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "Internet"
  }

  security_rule {
    name                       = "deny-vnet-outbound"
    priority                   = 4001
    direction                  = "Outbound"
    access                     = "Deny"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "VirtualNetwork"
    destination_address_prefix = "VirtualNetwork"
  }


  tags = local.tags
}

resource "azurerm_network_security_group" "pe" {
  name                = "nsg-pe-uks-dev"
  location            = azurerm_resource_group.app.location
  resource_group_name = azurerm_resource_group.app.name

  security_rule {
    name                       = "allow-app-https-inbound"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefixes    = azurerm_subnet.app.address_prefixes
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "deny-vnet-inbound"
    priority                   = 4000
    direction                  = "Inbound"
    access                     = "Deny"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "VirtualNetwork"
    destination_address_prefix = "*"
  }

  tags = local.tags
}

resource "azurerm_subnet_network_security_group_association" "app" {
  subnet_id                 = azurerm_subnet.app.id
  network_security_group_id = azurerm_network_security_group.app.id
}

resource "azurerm_subnet_network_security_group_association" "pe" {
  subnet_id                 = azurerm_subnet.pe.id
  network_security_group_id = azurerm_network_security_group.pe.id
}
