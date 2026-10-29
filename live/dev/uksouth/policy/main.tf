locals {
  location    = "UK South"
  name_suffix = "uks-dev"

  tags = {
    owner   = "kenneth"
    purpose = "policy guardrails test"
    chapter = "J07"
  }
}

# Test scope: assignments live on one resource group, not the subscription, so a deny
# can't break the core stack while it's being proven.
resource "azurerm_resource_group" "policy_test" {
  name     = "rg-policy-test-${local.name_suffix}"
  location = local.location
  tags     = local.tags
}

data "azurerm_policy_definition_built_in" "storage_public_access" {
  display_name = "Storage account public access should be disallowed"
}

data "azurerm_policy_definition_built_in" "require_tag" {
  display_name = "Require a tag on resources"
}

# Public storage: one right answer, so block it at request time.
resource "azurerm_resource_group_policy_assignment" "deny_public_storage" {
  name                 = "deny-public-storage"
  display_name         = "Deny public storage accounts"
  resource_group_id    = azurerm_resource_group.policy_test.id
  policy_definition_id = data.azurerm_policy_definition_built_in.storage_public_access.id

  parameters = jsonencode({
    effect = { value = "Deny" }
  })

  non_compliance_message {
    content = "Storage accounts must not allow public blob access. Set allow_nested_items_to_be_public = false."
  }
}

# Owner tag: the built-in is hard-coded to deny, and Azure creates some resources itself,
# so report only (enforce = false is DoNotEnforce). Flip to true once teams are clean.
resource "azurerm_resource_group_policy_assignment" "require_owner_tag" {
  name                 = "require-owner-tag"
  display_name         = "Require owner tag (report only)"
  resource_group_id    = azurerm_resource_group.policy_test.id
  policy_definition_id = data.azurerm_policy_definition_built_in.require_tag.id
  enforce              = false

  parameters = jsonencode({
    tagName = { value = "owner" }
  })
}
