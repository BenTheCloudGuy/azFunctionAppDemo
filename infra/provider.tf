terraform {
  required_version = "~> 1.11.0"

  required_providers {
    azapi = {
      source  = "azure/azapi"
      version = "~>2.3.0"
    }
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>4.25.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~>3.7.0"
    }
  }
}

provider "azurerm" {
  features {}
  subscription_id = "d79627b1-6f38-4296-92ae-6de3c9d881a4"
}