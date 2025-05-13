output "log_analytics_workspace_id" {
  value = azurerm_log_analytics_workspace.log_analytics.id
}

output "resource_group_name" {
  value = data.azurerm_resource_group.rg.name
}

output "FunctionAppName" {
  value = azurerm_windows_function_app.func_app.name
}