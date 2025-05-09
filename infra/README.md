# Terraform Workspace #

Detailed description of Terraform Templates go here!! 

### backend.tf ###

The purpose of backend.tf is to define how Terraform manages and stores its state data. Terraform uses persisted state data to track the resources it provisions and manages. By configuring a backend, such as AzureRM, you enable Terraform to store state remotely in a secure and shared location. This approach allows multiple team members to access and collaborate on the same infrastructure resources simultaneously, ensuring consistency, preventing conflicts, and facilitating effective teamwork.  

```json
terraform {
  backend "azurerm" {
    resource_group_name  = "<resource_group_name>"
    storage_account_name = "<storage_account_name_for_tfstate>"
    container_name       = "tfstate"
    key                  = "funcAppDemo.tfstate>"
    tenant_id            = "<tenant_id>"
    use_azuread_auth     = true
  }
}
```
> **NOTE**  
> Learn More: https://developer.hashicorp.com/terraform/language/backend

### provider.tf ###

The purpose of provider.tf is to define and configure the providers Terraform uses to interact with external systems, such as Azure. Providers enable Terraform to provision and manage resources within specific cloud platforms or services. Before Terraform can utilize these providers, configurations must explicitly declare required providers, specifying details such as source and version constraints. This ensures Terraform can automatically install and manage the correct provider versions. Additionally, provider configurations, such as Azure regions, subscription IDs, or authentication methods, must be defined clearly, enabling Terraform to interact effectively with the target cloud environment.

```json
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
    subscription_id = "<subscription_id>"
}
```

> **NOTE**  
> Learn More: https://developer.hashicorp.com/terraform/language/providers/configuration

### locals.tf ###

Purpose of locals.tf

```json
locals {
  location            = "northcentralus"
  resource_group_name = "green-hamster"
}
```

### import.tf ###

Purpose of import.tf

```json
# This will import the resource group and allow you to manage it with this Terraform configuration.
import {
  id = var.resource_group_id
  to = azurerm_resource_group.main
}
```


### vars.tf ###

Purpose of the vars.tf
