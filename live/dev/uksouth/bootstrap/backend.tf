terraform {
  backend "azurerm" {
    resource_group_name  = "rg-tfstate-uks-devsecjob"
    storage_account_name = "hex001paytfstate001"
    container_name       = "tfstate"
    key                  = "dev/uksouth/bootstrap/terraform.tfstate"
    use_azuread_auth     = true
  }
}