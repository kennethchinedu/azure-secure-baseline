variable "name" {
  description = "Virtual network name"
  type        = string
}

variable "resource_group_name" {
  description = "Resource group for the VNet, subnets and NSGs"
  type        = string
}

variable "location" {
  description = "Azure region"
  type        = string
}

variable "address_space" {
  description = "VNet address ranges"
  type        = list(string)
}

variable "subnets" {
  description = <<-EOT
    Subnets keyed by a short role name (e.g. "app", "pe"). Every subnet gets its own NSG:
    a subnet without one is filtered only by Azure's open-inside-the-VNet defaults.
    The NSGs are created empty; the caller adds rules as azurerm_network_security_rule resources.
  EOT
  type = map(object({
    name                              = string
    address_prefixes                  = list(string)
    nsg_name                          = string
    default_outbound_access_enabled   = optional(bool, false)
    private_endpoint_network_policies = optional(string, "Disabled")
  }))

  validation {
    condition = alltrue([
      for s in values(var.subnets) : contains(["Enabled", "Disabled"], s.private_endpoint_network_policies)
    ])
    error_message = "private_endpoint_network_policies must be Enabled or Disabled."
  }
}

variable "tags" {
  description = "Tags for the VNet and NSGs (subnets don't take tags)"
  type        = map(string)
  default     = {}
}
