
resource "azurerm_key_vault" "this" {
  name                = var.name
  resource_group_name = var.resource_group_name
  location            = var.location
  tenant_id           = var.tenant_id

  sku_name                   = "standard"
  rbac_authorization_enabled = true

  soft_delete_retention_days = 7
  purge_protection_enabled   = false

  public_network_access_enabled = true

  network_acls {
    bypass         = "None"
    default_action = "Deny"
    ip_rules       = var.allowed_ip_ranges
  }

  tags = var.tags
}

# Write access: create, update, delete secrets. Grant to groups and the Terraform operator.
resource "azurerm_role_assignment" "secrets_officer" {
  for_each = var.secrets_officers

  scope                = azurerm_key_vault.this.id
  role_definition_name = "Key Vault Secrets Officer"
  principal_id         = each.value
}

# Read-only access for workloads. Least privilege: an app reads its secret, it never manages the vault.
resource "azurerm_role_assignment" "secrets_user" {
  for_each = var.secrets_users

  scope                = azurerm_key_vault.this.id
  role_definition_name = "Key Vault Secrets User"
  principal_id         = each.value
}
