terraform {
  required_version = "1.11.4"
  backend "azurerm" {
    resource_group_name  = "stazgreenhamster01"
    storage_account_name = "stazgreenhamster01"
    container_name       = "tfstate"
    key                  = "greenhamster.tfstate" #Only change location after infrastructure/tenant/subscription/region/resource group
    use_azuread_auth     = true
  }
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 4.27.0"
    }
  }
}


provider "azurerm" {
  features {}
  subscription_id = "26e08660-7282-4a46-8a5f-790fafe6100b"
}
