## Create Managed Identity for Resources to Use and Assign Role(s) to it
resource "azurerm_user_assigned_identity" "identity" {
  name                = var.managed_identity_name
  resource_group_name = data.azurerm_resource_group.rg.name
  location            = data.azurerm_resource_group.rg.location
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
  os_type             = "Windows" # Changed to Windows
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

## Update Function App to Windows
resource "azurerm_windows_function_app" "func_app" {
  name                          = "${data.azurerm_resource_group.rg.name}-funcapp"
  resource_group_name           = data.azurerm_resource_group.rg.name
  location                      = data.azurerm_resource_group.rg.location
  service_plan_id               = azurerm_service_plan.funcapp_asp.id
  storage_account_name          = azurerm_storage_account.drop_storage.name
  storage_uses_managed_identity = true
  https_only                    = true
  functions_extension_version   = "~4"
  identity {
    type         = "SystemAssigned, UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.identity.id]
  }
  site_config {
    always_on                              = true
    application_insights_connection_string = azurerm_application_insights.app_insights.connection_string
    application_insights_key               = azurerm_application_insights.app_insights.instrumentation_key

  }
  app_settings = {
    AzureWebJobsStorage__accountName               = azurerm_storage_account.drop_storage.name
    AzureWebJobsStorage__blobServiceUri            = azurerm_storage_account.drop_storage.primary_blob_endpoint
    AzureWebJobsStorage__queueServiceUri           = azurerm_storage_account.drop_storage.primary_queue_endpoint
    AzureWebJobsStorage__tableServiceUri           = azurerm_storage_account.drop_storage.primary_table_endpoint
    AzureWebJobsStorage__managedIdentityResourceId = azurerm_user_assigned_identity.identity.id
    FUNCTIONS_WORKER_RUNTIME                       = "powershell"
    FUNCTIONS_WORKER_RUNTIME_VERSION               = "7.4"
    APPINSIGHTS_INSTRUMENTATIONKEY                 = azurerm_application_insights.app_insights.instrumentation_key
    APPLICATIONINSIGHTS_CONNECTION_STRING          = azurerm_application_insights.app_insights.connection_string
    archive_container_name                         = azurerm_storage_container.archive_container.name
  }
}



## Following 3 Roles are required for the FunctionApp to access the Storage Account
## User Assigned Identity
resource "azurerm_role_assignment" "uami_blob_data_owner" {
  principal_id         = azurerm_user_assigned_identity.identity.principal_id
  role_definition_name = "Storage Blob Data Owner"
  scope                = data.azurerm_resource_group.rg.id
}

resource "azurerm_role_assignment" "uami_queue_data_contributor" {
  principal_id         = azurerm_user_assigned_identity.identity.principal_id
  role_definition_name = "Storage Queue Data Contributor"
  scope                = data.azurerm_resource_group.rg.id
}

resource "azurerm_role_assignment" "uami_storage_account_contributor" {
  principal_id         = azurerm_user_assigned_identity.identity.principal_id
  role_definition_name = "Storage Account Contributor"
  scope                = data.azurerm_resource_group.rg.id
}

## Following 3 Roles are required for the FunctionApp to access the Storage Account
### FunctionApp System Assigned Identity
resource "azurerm_role_assignment" "sami_blob_data_owner" {
  principal_id         = azurerm_windows_function_app.func_app.identity[0].principal_id
  role_definition_name = "Storage Blob Data Owner"
  scope                = data.azurerm_resource_group.rg.id
  # Explicit dependency on the Function App
  depends_on = [azurerm_windows_function_app.func_app]
}


resource "azurerm_role_assignment" "sami_queue_data_contributor" {
  principal_id         = azurerm_windows_function_app.func_app.identity[0].principal_id
  role_definition_name = "Storage Queue Data Contributor"
  scope                = data.azurerm_resource_group.rg.id
  # Explicit dependency on the Function App
  depends_on = [azurerm_windows_function_app.func_app]
}


resource "azurerm_role_assignment" "sami_storage_account_contributor" {
  principal_id         = azurerm_windows_function_app.func_app.identity[0].principal_id
  role_definition_name = "Storage Account Contributor"
  scope                = data.azurerm_resource_group.rg.id
  # Explicit dependency on the Function App
  depends_on = [azurerm_windows_function_app.func_app]
}


