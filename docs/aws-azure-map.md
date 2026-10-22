# AWS ↔ Azure map

| Control | Azure | AWS | How it differs |
|---|---|---|---|
| Secret store | Key Vault (RBAC mode) | Secrets Manager | Key Vault separates management plane (ARM roles) from data plane (`dataActions`); Owner can't read secrets without a data role |
| Private access to a PaaS service | Private Endpoint (NIC in a subnet) | Interface VPC endpoint (PrivateLink) | Same mechanism |
| Private DNS for that endpoint | Private DNS zone `privatelink.*` + VNet link, A record via zone group | `private_dns_enabled = true` (AWS-managed hosted zone) | Azure exposes the zone, link and record as separate resources |
| Zone visible to a network | Virtual network link | Private hosted zone associated with a VPC | Neither follows peering |
| Endpoint traffic filtering | NSG on the endpoint subnet, only with network policies `Enabled` | Security group on the endpoint ENI | AWS always applies the SG; Azure ignores the NSG by default |
