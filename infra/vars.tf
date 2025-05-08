variable "location" {
  description = "The Azure region where resources will be deployed."
  type        = string
  default     = "northcentralus"
}

variable "managed_identity_name" {
  description = "The name of the User Defined Managed Identity."
  type        = string
}

variable "storage_account_name" {
  description = "The name of the Storage Account."
  type        = string
}

variable "container_name" {
  description = "The name of the container within the Storage Account."
  type        = string
}

variable "app_service_plan_name" {
  description = "The name of the App Service Plan."
  type        = string
}

variable "web_frontend_name" {
  description = "The name of the Web Frontend (Python)."
  type        = string
}

variable "function_app_name" {
  description = "The name of the Function App (PowerShell)."
  type        = string
}

variable "sql_server_name" {
  description = "The name of the SQL Server."
  type        = string
}

variable "sql_database_name" {
  description = "The name of the SQL Database."
  type        = string
}

variable "admin_username" {
  description = "The admin username for the SQL Database."
  type        = string
}

variable "admin_password" {
  description = "The admin password for the SQL Database."
  type        = string
  sensitive   = true
}

variable "key_vault_name" {
  description = "The name of the Key Vault."
  type        = string
}