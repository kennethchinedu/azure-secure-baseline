variable "name" {
  description = "VM name; the NIC is named <name>-nic."
  type        = string
}

variable "resource_group_name" {
  description = "Resource group for the VM and its NIC."
  type        = string
}

variable "location" {
  description = "Azure region; must match the subnet's VNet."
  type        = string
}

variable "subnet_id" {
  description = "Subnet for the VM's private NIC."
  type        = string
}

variable "size" {
  description = "VM size. Must support trusted launch (Gen2, x64). In UK South, B1s had no capacity and Basv2 had zero quota on this subscription."
  type        = string
  default     = "Standard_D2as_v4"
}

variable "admin_username" {
  description = "Local admin user."
  type        = string
  default     = "azureuser"
}

variable "admin_ssh_public_key" {
  description = "SSH public key (ssh-rsa or ssh-ed25519) for the admin user."
  type        = string
}

variable "tags" {
  description = "Tags to apply to the VM and NIC."
  type        = map(string)
  default     = {}
}
