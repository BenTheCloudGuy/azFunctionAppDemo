
variable "resource_group_id" {
  description = "The ResourceId ofo the Resource Group that will be imported into the Terraform State so it can be managed by Terraform."
  type        = string
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
