# Remote state for every stack in this repo. Access is Entra ID only: shared keys are off,
# so a leaked account key can't exist, and every read/write is an RBAC decision in the audit log.
resource "azurerm_storage_account" "this" {
  name                = var.name
  resource_group_name = var.resource_group_name
  location            = var.location

  account_tier             = "Standard"
  account_replication_type = var.account_replication_type

  https_traffic_only_enabled      = true
  min_tls_version                 = "TLS1_2"
  allow_nested_items_to_be_public = false
  shared_access_key_enabled       = false

  blob_properties {
    # Every state write keeps the previous version: a bad apply can be rolled back.
    versioning_enabled = true

    delete_retention_policy {
      days = var.blob_retention_days
    }

    container_delete_retention_policy {
      days = var.container_retention_days
    }
  }

  tags = var.tags
}

# Data plane access. Owner on the subscription doesn't include it.
resource "azurerm_role_assignment" "blob_data" {
  for_each = var.blob_data_contributors

  scope                = azurerm_storage_account.this.id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = each.value
}

resource "azurerm_storage_container" "this" {
  name                  = var.container_name
  storage_account_id    = azurerm_storage_account.this.id
  container_access_type = "private"

  # Created over the data plane, so the role assignment must exist first.
  depends_on = [azurerm_role_assignment.blob_data]
}
