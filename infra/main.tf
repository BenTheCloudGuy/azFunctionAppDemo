## Create Managed Identity for Resources to Use and Assign Role(s) to it
resource "azurerm_user_assigned_identity" "identity" {
  name                = var.managed_identity_name
  resource_group_name = data.azurerm_resource_group.rg.name
  location            = data.azurerm_resource_group.rg.location
}

resource "azurerm_role_assignment" "identity_blob_data_contributor" {
  principal_id         = azurerm_user_assigned_identity.identity.principal_id
  role_definition_name = "Storage Blob Data Contributor"
  scope                = data.azurerm_resource_group.rg.id
}

## Create Storage Account and Containers
resource "azurerm_storage_account" "drop_storage" {
  name                              = var.storage_account_name
  resource_group_name               = data.azurerm_resource_group.rg.name
  location                          = data.azurerm_resource_group.rg.location
  account_tier                      = "Standard"
  account_replication_type          = "LRS"
  public_network_access_enabled     = true
  large_file_share_enabled          = true
  infrastructure_encryption_enabled = true
  allow_nested_items_to_be_public   = false
}

resource "azurerm_storage_container" "drop_container" {
  name                  = var.container_name
  storage_account_id    = azurerm_storage_account.drop_storage.id
  container_access_type = "private"
}

resource "azurerm_storage_container" "archive_container" {
  name                  = "archive"
  storage_account_id    = azurerm_storage_account.drop_storage.id
  container_access_type = "private"
}

resource "azurerm_storage_management_policy" "archive_policy" {
  storage_account_id = azurerm_storage_account.drop_storage.id

  rule {
    name    = "archive-rule"
    enabled = true

    filters {
      blob_types   = ["blockBlob"]
      prefix_match = ["archive/"]
    }

    actions {
      base_blob {
        tier_to_archive_after_days_since_modification_greater_than = 0
        delete_after_days_since_modification_greater_than          = 30
      }
      snapshot {
        delete_after_days_since_creation_greater_than = 30
      }
    }
  }
}

## Create App Service Plan for FunctionApp and WebApp
resource "azurerm_service_plan" "funcapp_asp" {
  name                = "${data.azurerm_resource_group.rg.name}-asp"
  resource_group_name = data.azurerm_resource_group.rg.name
  location            = data.azurerm_resource_group.rg.location
  os_type             = "Linux"
  sku_name            = "S1"
}

## Create Log Analytics Workspace
resource "azurerm_log_analytics_workspace" "log_analytics" {
  name                = "${data.azurerm_resource_group.rg.name}-loganalytics"
  resource_group_name = data.azurerm_resource_group.rg.name
  location            = data.azurerm_resource_group.rg.location
  sku                 = "PerGB2018"
  retention_in_days   = 30
}

## Create Application Insights for FunctionApp and WebApp
resource "azurerm_application_insights" "app_insights" {
  name                = "${data.azurerm_resource_group.rg.name}-appinsights"
  resource_group_name = data.azurerm_resource_group.rg.name
  location            = data.azurerm_resource_group.rg.location
  application_type    = "web"
  workspace_id        = azurerm_log_analytics_workspace.log_analytics.id
}

resource "azurerm_linux_function_app" "func_app" {
  name                       = "${data.azurerm_resource_group.rg.name}-funcapp"
  resource_group_name        = data.azurerm_resource_group.rg.name
  location                   = data.azurerm_resource_group.rg.location
  service_plan_id            = azurerm_service_plan.funcapp_asp.id
  storage_account_name       = azurerm_storage_account.drop_storage.name
  storage_account_access_key = azurerm_storage_account.drop_storage.primary_access_key
  identity {
    type = "UserAssigned"
    identity_ids = [
      azurerm_user_assigned_identity.identity.id,
    ]
  }
  site_config {
    always_on = true
  }
  app_settings = {
    AzureWebJobsStorage                   = ""
    FUNCTIONS_WORKER_RUNTIME              = "powershell"
    FUNCTIONS_WORKER_RUNTIME_VERSION      = "7.4"
    APPINSIGHTS_INSTRUMENTATIONKEY        = azurerm_application_insights.app_insights.instrumentation_key
    APPLICATIONINSIGHTS_CONNECTION_STRING = azurerm_application_insights.app_insights.connection_string
  }
}
## https://learn.microsoft.com/en-us/azure/azure-functions/functions-app-settings#functions_extension_version
