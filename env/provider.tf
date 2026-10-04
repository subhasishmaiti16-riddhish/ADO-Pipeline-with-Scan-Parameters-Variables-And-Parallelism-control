terraform {

  required_version = ">= 1.5.0"
  required_providers {

    azurerm = {
      source  = "hashicorp/azurerm"
      version = "5.2.0"
    }
  }
  backend "azurerm" {
    resource_group_name  = "rg-devops"
    storage_account_name = "datablockstorage"
    container_name       = "aksstoragecont"
    key                  = "preprod.aksstoragecont"

  }
}
provider "azurerm" {
  features {}

}
