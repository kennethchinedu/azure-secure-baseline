# Bootstrap: the storage that holds every stack's state, this one included.
# First apply runs with local state; backend.tf then moves the state into the account it created.

data "azurerm_client_config" "current" {}

resource "azurerm_resource_group" "tfstate" {
  name     = var.resource_group_name
  location = var.location
}

module "state_storage" {
  source = "../../../../modules/state-storage"

  name                     = var.storage_account_name
  resource_group_name      = azurerm_resource_group.tfstate.name
  location                 = azurerm_resource_group.tfstate.location
  account_replication_type = var.account_replication_type
  blob_retention_days      = var.state_file_retention_days
  container_retention_days = var.container_retention_days

  # Whoever runs Terraform needs data plane access to the state.
  blob_data_contributors = {
    terraform_operator = data.azurerm_client_config.current.object_id
  }
}
