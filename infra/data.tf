# Collect data about the current client configuration
data "azurerm_client_config" "current" {
  provider = azurerm
}

# Collect data about the current Resource Group
data "azurerm_resource_group" "rg" {
  name = element(split("/", var.resource_group_id), length(split("/", var.resource_group_id)) - 1)
}