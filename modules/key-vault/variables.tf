
variable "name" {
  description = "Globally unique Key Vault name, 3–24 characters."
  type        = string

  validation {
    condition     = length(var.name) >= 3 && length(var.name) <= 24 && can(regex("^[a-zA-Z0-9-]+$", var.name))
    error_message = "Key Vault name must be 3–24 characters and contain only letters, numbers, and hyphens."
  }
}

variable "resource_group_name" {
  description = "Name of the resource group for the Key Vault."
  type        = string
}

variable "location" {
  description = "Azure region where the Key Vault will be deployed."
  type        = string
}

variable "tenant_id" {
  description = "Microsoft Entra tenant ID."
  type        = string
}

variable "allowed_ip_ranges" {
  description = "Public IP addresses or CIDR ranges allowed to access the Key Vault."
  type        = list(string)
  default     = []
}

variable "secrets_officers" {
  description = "Map of labels to Microsoft Entra principal object IDs for Key Vault Secrets Officer assignments."
  type        = map(string)
  default     = {}
}

variable "secrets_users" {
  description = "Map of labels to principal object IDs that may only READ secrets (Key Vault Secrets User), e.g. a workload's managed identity."
  type        = map(string)
  default     = {}
}

variable "tags" {
  description = "Tags to apply to the Key Vault."
  type        = map(string)
  default     = {}
}

