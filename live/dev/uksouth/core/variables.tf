variable "allowed_ip_ranges" {
  type    = list(string)
  default = []

  description = "Operator public IPs allowed through the Key Vault firewall (set in gitignored terraform.tfvars)."
}

variable "extra_secrets_officers" {
  description = "Extra Key Vault Secrets Officers as { label = object ID }, set in gitignored terraform.tfvars. Prefer adding people to the officers group instead."
  type        = map(string)
  default     = {}
}

variable "vm_admin_ssh_public_key" {
  description = "SSH public key for the workload VM's admin user (set in gitignored terraform.tfvars)."
  type        = string
}
