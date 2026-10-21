# network

VNet, subnets, and one NSG per subnet with its association.

- Every subnet gets an NSG; there is no way to create one without it.
- Subnets are private by default (`default_outbound_access_enabled = false`).
- `private_endpoint_network_policies` per subnet: set `"Enabled"` on a private endpoint subnet so
  its NSG rules apply to endpoint traffic.
- NSGs are created **empty**. Add rules in the calling stack as `azurerm_network_security_rule`
  resources (`network_security_group_name = module.network.nsg_names["app"]`). Never add inline
  `security_rule` blocks to these NSGs as well: the two styles overwrite each other.

```hcl
module "network" {
  source = "../../../../modules/network"

  name                = "vnet-app-uks-dev"
  resource_group_name = azurerm_resource_group.app.name
  location            = "UK South"
  address_space       = ["10.30.0.0/16"]

  subnets = {
    app = {
      name             = "snet-app"
      address_prefixes = ["10.30.1.0/24"]
      nsg_name         = "nsg-app-uks-dev"
    }
  }
}
```

Outputs: `vnet_id`, `vnet_name`, `subnet_ids`, `subnet_address_prefixes`, `nsg_ids`, `nsg_names` (maps keyed by subnet role).
