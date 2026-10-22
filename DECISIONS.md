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
| Private endpoint as its own module | `modules/private-endpoint`: one endpoint, one sub-resource (validated), DNS zone group optional | Reusable for the state storage account (`blob`, gap 2). The zone group is skipped when records are managed centrally (Azure Policy in a hub), so Terraform and the policy don't overwrite each other | |
| Private DNS zones in the stack | `privatelink.vaultcore.azure.net` and its VNet link in `core/dns.tf`, not in a module | One zone per service per VNet, shared by every endpoint of that service; a module creating its own zone would collide on its second use | |
| Network policies on the endpoint subnet | `private_endpoint_network_policies = "Enabled"` on `snet-pe` | Default `Disabled` makes the subnet's NSG and route table ignore endpoint traffic: `nsg-pe` would filter nothing, and an endpoint's /32 route would bypass a firewall UDR | |
| Secret values not in Terraform | The vault and its access are Terraform; secret values are set by their owner (`az keyvault secret set`, later the app or rotation) | A secret resource stores its value in state, and Terraform would read it over the data plane, so every plan from outside the VNet would fail once public access is off | |
| Workload VM | `modules/linux-vm`: private NIC only, system-assigned identity, trusted launch, `Standard_D2as_v4` | The identity lives and dies with the VM; Secrets User at vault scope only. B1s had no capacity in UK South and Basv2 had zero quota on this subscription | |

## Known gaps

1. **No NSG flow logs or Network Watcher configuration yet.** Traffic decisions aren't recorded.
2. **State storage has no private endpoint.** It's reachable on its public endpoint, protected by Entra ID + RBAC only. Upgrade: network rules or a private endpoint once CI runners are in the VNet.
3. **Single operator identity.** The human operator holds Owner on the subscription; CI will use a federated identity with narrower roles. Production would grant Owner just-in-time through PIM.
4. **No resource locks** on the state storage. A `CanNotDelete` lock is the production setting.
5. **Repo hygiene:** no branch ruleset and no CI checks (fmt, validate, tflint, Checkov) yet.
6. **Key Vault public access still on** (operator IP only). It goes off once a workload in `snet-app` reads a secret through the endpoint; until then the endpoint path is unproven.
