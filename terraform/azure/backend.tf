terraform {
  backend "azurerm" {
    resource_group_name  = "<TFSTATE_RG_NAME>"
    storage_account_name = "<TFSTATE_STORAGE_ACCOUNT>"
    container_name       = "<TFSTATE_CONTAINER>"
    key                  = "multi-cloud/azure/aks.tfstate"
  }
}