# azure-secure-baseline

A secure Azure baseline in plain Terraform: Entra-only remote state, a default-deny network,
and (in progress) Key Vault reached only over a Private Endpoint by a workload's managed identity,
deployed from GitHub Actions with OIDC federation and no stored secrets.

It is the Azure counterpart of [aws-estate-project](https://github.com/kennethchinedu/aws-estate-project);
[docs/aws-azure-map.md](docs/aws-azure-map.md) maps each control across the two clouds.

## Status

| Area | Built | Planned |
|---|---|---|
| Remote state | Storage account with shared keys off (Entra ID + RBAC only), TLS 1.2, no public blobs, versioning, 30-day soft delete | |
| Network | VNet `10.30.0.0/16`, private subnets (no default outbound), one NSG per subnet, default-deny rules | NSG flow logs |
| Secrets | | Key Vault (RBAC, public access off) + Private Endpoint + private DNS zone |
| Workload | | VM with managed identity reading the secret over the endpoint |
| CI/CD | | GitHub Actions → Entra workload identity federation (OIDC), plan on PR, apply from `main` |
| Posture | | Defender for Cloud recommendations reviewed |

## Layout

Plain Terraform, no wrappers. **Modules** are reusable and hold no state; **live/** is what gets
applied: one folder per environment, region and stack, each a root module with its own state file.

```
modules/
  state-storage/     storage account + private container for Terraform state, Entra-only access
  network/           VNet, subnets, one NSG per subnet (created empty) and its association
live/dev/uksouth/
  bootstrap/         the state storage itself (state migrated into it after the first apply)
  core/              application resource group, network, and the NSG rules (nsg-rules.tf)
docs/
  aws-azure-map.md   each control and its AWS equivalent
DECISIONS.md         design decisions and known gaps
TEST-LOG.md          every control test: prediction, result, deciding layer
```

State lives in one container, one blob per stack: `<env>/<region>/<stack>/terraform.tfstate`,
locked with blob leases.

## Network design

```
vnet-app-uks-dev 10.30.0.0/16
├── snet-app 10.30.1.0/24   nsg-app-uks-dev
│     out 100  Allow TCP 443  snet-app → snet-pe
│     out 4000 Deny  *        → Internet
│     out 4001 Deny  *        VNet → VNet
│     in  4000 Deny  *        Internet →
└── snet-pe  10.30.2.0/24   nsg-pe-uks-dev
      in  100  Allow TCP 443  snet-app →
      in  4000 Deny  *        VNet →
```

Azure's built-in rules allow all traffic inside the VNet (`AllowVnetInBound`/`AllowVnetOutBound`
at 65000), so each allow is fenced by an explicit deny with a higher number. From `snet-app` the only
permitted connection is TCP 443 to the private endpoint subnet; lateral movement and internet egress
are blocked. Each rule is its own `azurerm_network_security_rule` in `live/dev/uksouth/core/nsg-rules.tf`,
and references the address plan in `locals.tf`, never retyped CIDRs.

## Apply order

| # | Stack | Notes |
|---|---|---|
| 1 | `bootstrap` | First apply with local state (comment out `backend.tf`), then `terraform init -migrate-state`. Needs `terraform.tfvars` (copy `terraform.tfvars.example`). |
| 2 | `core` | No variables. |

### Prerequisites

- Terraform >= 1.9, Azure CLI signed in (`az login`).
- `export ARM_SUBSCRIPTION_ID=<subscription id>`. The subscription is sign-in context, not code,
  so no stack declares it; CI sets the same variable.
- Owner (or Contributor + User Access Administrator) on the subscription, to create role assignments.

## Teardown

`terraform destroy` in reverse order (`core`, then `bootstrap`). Destroying `bootstrap` deletes the
state of every stack, so it goes last and only once the others are gone.
