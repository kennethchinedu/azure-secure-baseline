# Access to the vault is granted to a group, not to people. Joiners and leavers are handled by
# changing group membership in Entra ID; the role assignments and this code never change.
resource "azuread_group" "kv_secrets_officers" {
  display_name     = "kv-app-${local.name_suffix}-secrets-officers"
  description      = "Can create, update and delete secrets in kv-app-${local.name_suffix}-kc"
  security_enabled = true
  owners           = [data.azurerm_client_config.current.object_id]

  # Membership is managed in Entra ID, not here: Terraform must not remove people it didn't add.
  lifecycle {
    ignore_changes = [members]
  }
}
