
variable "name" {
  description = "Name of the private endpoint."
  type        = string
}

variable "resource_group_name" {
  description = "Resource group that will contain the private endpoint."
  type        = string
}

variable "location" {
  description = "Azure region where the private endpoint will be deployed."
  type        = string
}

variable "subnet_id" {
  description = "ID of the subnet where the private endpoint will be placed."
  type        = string
}

variable "resource_id" {
  description = "ID of the Azure resource the private endpoint will connect to."
  type        = string
}

variable "subresource_names" {
  description = "Target sub-resource, such as vault for Key Vault or blob for Storage."
  type        = list(string)

  # Azure accepts one per endpoint (blob and file need two endpoints); fail at plan, not apply.
  validation {
    condition     = length(var.subresource_names) == 1
    error_message = "A private endpoint connects to exactly one sub-resource."
  }
}

variable "private_dns_zone_ids" {
  description = "Private DNS zones for the endpoint's A record. Empty when DNS records are managed centrally."
  type        = list(string)
  default     = []
}

variable "tags" {
  description = "Tags to apply to the private endpoint."
  type        = map(string)
  default     = {}
}
