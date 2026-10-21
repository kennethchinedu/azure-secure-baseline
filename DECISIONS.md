# Decisions

| Decision | How | Why | Proof |
|---|---|---|---|
| Entra-only state access | `shared_access_key_enabled = false`; `Storage Blob Data Contributor` for the operator; backend `use_azuread_auth = true` | No account key exists to leak; every state read/write is an RBAC decision in the activity log | State migrated and read back through the backend |
| Data plane role on the storage account only | Role assignment scoped to the account, not the resource group or subscription | Owner covers the control plane only; data access is granted at the narrowest scope | `az role assignment list --include-inherited` on `rg-app-uks-dev` doesn't show it (TEST-LOG 3) |
| Subscription from the environment | `ARM_SUBSCRIPTION_ID`, no `subscription_id` in code | Sign-in context, like `AWS_PROFILE`; identical code on a laptop and in CI | Both stacks plan with no variable declared |
| Backend values as literals | Written in `backend.tf` | `init` reads the backend before variables exist; names aren't secrets. Partial config (`-backend-config`) is the upgrade path for multiple environments | |
| Private subnets | `default_outbound_access_enabled = false` | Azure is retiring implicit outbound access; egress must be added on purpose (NAT gateway) | `az network vnet subnet list`: `defaultOutboundAccess: False` |
| One NSG per subnet | `modules/network` creates an NSG for every subnet; no opt-out | A shared NSG gives every subnet the union of all rules; per-role NSGs keep least privilege and a small blast radius | |
| Default deny inside the VNet | Explicit Deny at 4000/4001 after each Allow | Azure's defaults allow all VNet traffic at 65000; without the deny, an allow on 443 restricts nothing | TEST-LOG 5 |
| `VirtualNetwork` tag avoided in allows | Allows name subnet ranges from `locals.tf` | The tag also covers peered VNets and on-premises ranges behind a gateway | |
| NSG rules as separate resources | Module creates empty NSGs; each rule is an `azurerm_network_security_rule` in the stack; never inline `security_rule` blocks too | One readable block per rule, reviewable in a PR diff; mixing both styles makes each apply overwrite the other. Trade-off: no plan-time validation of priorities (Azure rejects duplicates at apply) | TEST-LOG 6 |
| Refactor with `moved` and `import` blocks | `moved` blocks re-addressed resources into the modules; `import` blocks adopted the six rules that already existed inside the NSGs. Both files were deleted once applied (state records the new addresses) | Live resources were never destroyed and recreated: 0 to add, 0 to change, 0 to destroy; both stacks plan **No changes** without the files | TEST-LOG 6 |

## Known gaps

1. **No NSG flow logs or Network Watcher configuration yet.** Traffic decisions aren't recorded.
2. **State storage has no private endpoint.** It's reachable on its public endpoint, protected by Entra ID + RBAC only. Upgrade: network rules or a private endpoint once CI runners are in the VNet.
3. **Single operator identity.** The human operator holds Owner on the subscription; CI will use a federated identity with narrower roles. Production would grant Owner just-in-time through PIM.
4. **No resource locks** on the state storage. A `CanNotDelete` lock is the production setting.
5. **Repo hygiene:** no branch ruleset and no CI checks (fmt, validate, tflint, Checkov) yet.
