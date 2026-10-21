
provider "azurerm" {

  features {
    key_vault {
      purge_soft_delete_on_destroy = true #So i can easily delete vault after this anytme
    }
  }

  storage_use_azuread = true
}

# Entra ID (users, groups). Uses the same az login session and tenant as azurerm.
provider "azuread" {}
