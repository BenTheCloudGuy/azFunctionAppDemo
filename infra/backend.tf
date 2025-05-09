terraform {
  backend "azurerm" {
    resource_group_name  = "cglabs-azfuncdemo"
    storage_account_name = "cglabstffuncdemosa"
    container_name       = "tfstate"
    key                  = "funcApp.demo.tfstate"
    tenant_id            = "477bacc4-4ada-4431-940b-b91cf6cb3fd4"
    use_azuread_auth     = true
  }
}
