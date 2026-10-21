variable "name" {
  description = "Globally unique storage account name (3-24 lowercase letters and numbers)"
  type        = string

  validation {
    condition     = can(regex("^[a-z0-9]{3,24}$", var.name))
    error_message = "Use 3-24 lowercase letters and numbers."
  }
}

variable "resource_group_name" {
  description = "Resource group the storage account is created in"
  type        = string
}

variable "location" {
  description = "Azure region"
  type        = string
}

variable "account_replication_type" {
  description = "Storage replication strategy"
  type        = string
  default     = "LRS"

  validation {
    condition     = contains(["LRS", "ZRS", "GRS", "GZRS"], var.account_replication_type)
    error_message = "Use LRS, ZRS, GRS, or GZRS."
  }
}

variable "container_name" {
  description = "Private blob container that holds the state files"
  type        = string
  default     = "tfstate"
}

variable "blob_retention_days" {
  description = "Days a deleted or overwritten state blob can be recovered (soft delete)"
  type        = number

  validation {
    condition     = var.blob_retention_days >= 1 && var.blob_retention_days <= 365
    error_message = "Use 1-365 days."
  }
}

variable "container_retention_days" {
  description = "Days a deleted container can be recovered (soft delete)"
  type        = number

  validation {
    condition     = var.container_retention_days >= 1 && var.container_retention_days <= 365
    error_message = "Use 1-365 days."
  }
}

variable "blob_data_contributors" {
  description = "Principals that read and write state, as { label = principal object ID }. Shared keys are disabled, so state access is Entra ID + RBAC only."
  type        = map(string)
}

variable "tags" {
  description = "Tags applied to the storage account"
  type        = map(string)
  default     = {}
}
