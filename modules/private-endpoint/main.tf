# A NIC in the endpoint subnet with a private IP that leads to one sub-resource of one Azure resource.
resource "azurerm_private_endpoint" "this" {
  name                          = var.name
  location                      = var.location # must match the subnet's VNet; the target can be elsewhere
  resource_group_name           = var.resource_group_name
  subnet_id                     = var.subnet_id
  custom_network_interface_name = "${var.name}-nic" # instead of <name>.nic.<guid>

  private_service_connection {
    name                           = "${var.name}-connection"
    private_connection_resource_id = var.resource_id
    subresource_names              = var.subresource_names
    is_manual_connection           = false # auto-approved: the caller has rights on the target
  }

  # Writes the A record <resource>.privatelink.<zone> → private IP, and removes it with the endpoint.
  # Skipped when DNS is managed centrally (e.g. an Azure Policy in a hub creates the records).
  dynamic "private_dns_zone_group" {
    for_each = length(var.private_dns_zone_ids) > 0 ? [1] : []

    content {
      name                 = "default"
      private_dns_zone_ids = var.private_dns_zone_ids
    }
  }

  tags = var.tags
}
