output "log_analytics_workspace_id" {
  value = azurerm_log_analytics_workspace.log_analytics.id
}

output "FunctionAppName" {
  value = azurerm_function_app.functionapp.name
}