variable "location" {
  description = "Azure region for the Terraform state resources"
  type        = string
  default     = "UK South"
}

variable "resource_group_name" {
  description = "Resource group containing the Terraform state storage"
  type        = string
}

variable "storage_account_name" {
  description = "Globally unique Azure storage account name (3-24 lowercase letters and numbers)"
  type        = string
}

variable "account_replication_type" {
  description = "Storage replication strategy"
  type        = string
  default     = "LRS"

  validation {
    condition = contains(
      ["LRS", "ZRS", "GRS", "GZRS"],
      var.account_replication_type
    )
    error_message = "Use LRS, ZRS, GRS, or GZRS."
  }
}

variable "state_file_retention_days" {
  description = "Number of days to retain deleted blobs"
  type        = number
}

variable "container_retention_days" {
  description = "Number of days to retain deleted containers"
  type        = number
}
