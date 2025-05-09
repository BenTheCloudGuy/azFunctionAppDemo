resource "azurerm_resource_group" "main" {
  name     = data.azurerm_resource_group.rg.name
  location = data.azurerm_resource_group.rg.location
}

resource "azurerm_user_assigned_identity" "identity" {
  name                = var.managed_identity_name
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
}

resource "azurerm_storage_account" "drop_storage" {
  name                              = var.storage_account_name
  resource_group_name               = azurerm_resource_group.main.name
  location                          = azurerm_resource_group.main.location
  account_tier                      = "Standard"
  account_replication_type          = "LRS"
  public_network_access_enabled     = true
  large_file_share_enabled          = true
  infrastructure_encryption_enabled = true
  allow_nested_items_to_be_public   = false
}

resource "azurerm_storage_container" "drop_container" {
  name                  = var.container_name
  storage_account_id    = azurerm_storage_account.storage.id
  container_access_type = "private"
}

resource "azurerm_service_plan" "funcapp_asp" {
  name                = var.app_service_plan_name
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  os_type             = "Linux"
  sku_name            = "S1"
}