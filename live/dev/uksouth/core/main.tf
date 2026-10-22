data "azurerm_client_config" "current" {}

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

      # Default is Disabled: the subnet's NSG and route table then ignore endpoint traffic.
      private_endpoint_network_policies = "Enabled"
    }
  }
}

module "key_vault" {
  source = "../../../../modules/key-vault"

  name                = "kv-app-uks-dev-kc"
  resource_group_name = azurerm_resource_group.app.name
  location            = azurerm_resource_group.app.location
  tenant_id           = data.azurerm_client_config.current.tenant_id

  allowed_ip_ranges = var.allowed_ip_ranges

  # Keys are the identity of each role assignment in state: renaming a key destroys and recreates it.
  secrets_officers = merge(
    {
      terraform_operator = data.azurerm_client_config.current.object_id # whoever runs Terraform
      officers_group     = azuread_group.kv_secrets_officers.object_id
    },
    var.extra_secrets_officers, # break-glass or one-off grants, from gitignored terraform.tfvars
  )

  # Read-only: the workload reads its secret, never manages the vault.
  secrets_users = {
    workload_vm = module.workload_vm.principal_id
  }

  tags = local.tags
}

# The vault's private IP in snet-pe. Public access stays on (operator IP only) until the
# workload VM can reach the vault through this endpoint.
module "key_vault_private_endpoint" {
  source = "../../../../modules/private-endpoint"

  name                = "pe-kv-app-${local.name_suffix}"
  resource_group_name = azurerm_resource_group.app.name
  location            = azurerm_resource_group.app.location
  subnet_id           = module.network.subnet_ids["pe"]

  resource_id          = module.key_vault.id
  subresource_names    = ["vault"]
  private_dns_zone_ids = [azurerm_private_dns_zone.key_vault.id]

  tags = local.tags
}
