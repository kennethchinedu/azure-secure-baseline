# state-storage

Storage account and private container for Terraform remote state, with Entra ID as the only way in.

- Shared keys disabled: no account key exists, so backends must use `use_azuread_auth = true`.
- TLS 1.2 minimum, HTTPS only, no public blob access.
- Blob versioning plus soft delete for blobs and containers, so a bad write or delete can be recovered.
- `Storage Blob Data Contributor` for each principal in `blob_data_contributors`, scoped to this account.
  Owner on the subscription is control plane only and can't read state without it.

```hcl
module "state_storage" {
  source = "../../../../modules/state-storage"

  name                     = "examplestate001"
  resource_group_name      = azurerm_resource_group.tfstate.name
  location                 = "UK South"
  blob_retention_days      = 30
  container_retention_days = 30
  blob_data_contributors   = { terraform_operator = data.azurerm_client_config.current.object_id }
}
```

Outputs: `storage_account_id`, `storage_account_name`, `container_name`.
