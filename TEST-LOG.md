# Test log

Every test: prediction written **before** running. Where I didn't predict, it says so.

| # | Date | Test | Prediction | Actual result | Deciding layer | Notes |
|---|---|---|---|---|---|---|
| 1 | 2026-10-19 | First apply of `bootstrap`: container created right after its role assignment | 403 on the container (RBAC propagation lag), pass on re-apply | Created first time | `depends_on` on the role assignment | Propagation was fast enough; the lag is real but not every time |
| 2 | 2026-10-20 | `terraform init -migrate-state` to the azurerm backend | none | Blob `dev/uksouth/bootstrap/terraform.tfstate`, 16,861 B (same as local), lease `available` | backend `use_azuread_auth` + Blob Data Contributor | Earlier attempts: `var.` in `backend.tf` → "Variables not allowed" |
| 3 | 2026-10-20 | Role assignments visible on a new, empty resource group (`--include-inherited`) | Owner | Owner (subscription), Contributor (subscription, a service principal), Security Admin (root management group); no blob roles | RBAC inheritance: down from parent scopes only, never sideways | The service principal finding is tracked separately |
| 4 | 2026-10-21 | Both subnets have an NSG attached | both attached | `snet-app` → `nsg-app-uks-dev`, `snet-pe` → `nsg-pe-uks-dev` | `azurerm_subnet_network_security_group_association` | An earlier apply created the NSG without associations: "1 added" instead of 4 |
| 5 | 2026-10-21 | Reasoning: VM in `snet-app` → `snet-pe` on TCP 5432, before rule 4001 | Allowed, by `AllowVnetOutBound` (65000) | Not run (no VM yet) | NSG default rule | Led to the 4001 deny; to be run live once the VM exists |
| 6 | 2026-10-21 | Refactor into modules: plan after `moved` and `import` blocks | 0 to add / change / destroy | bootstrap: 3 moved, 0/0/0; core: 7 moved + 6 rules imported, 0/0/0. Applied, files removed, both stacks: No changes | `moved` / `import` blocks | |
