# Private NIC: no public IP, so the VM is reachable only from inside the VNet (or via run-command).
resource "azurerm_network_interface" "this" {
  name                = "${var.name}-nic"
  location            = var.location
  resource_group_name = var.resource_group_name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = var.subnet_id
    private_ip_address_allocation = "Dynamic"
  }

  tags = var.tags
}

resource "azurerm_linux_virtual_machine" "this" {
  name                  = var.name
  location              = var.location
  resource_group_name   = var.resource_group_name
  size                  = var.size
  network_interface_ids = [azurerm_network_interface.this.id]

  # SSH key only; there is no inbound path to use it, but Azure requires an admin credential.
  admin_username                  = var.admin_username
  disable_password_authentication = true

  admin_ssh_key {
    username   = var.admin_username
    public_key = var.admin_ssh_public_key
  }

  # System-assigned: the identity is created and deleted with the VM, so no orphaned principal keeps
  # its role assignments. A user-assigned identity is the choice when roles must exist before the VM.
  identity {
    type = "SystemAssigned"
  }

  # Trusted launch: Secure Boot blocks unsigned boot components; vTPM enables measured boot.
  secure_boot_enabled = true
  vtpm_enabled        = true

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "ubuntu-24_04-lts"
    sku       = "server" # Gen2 image, required for trusted launch
    version   = "latest"
  }

  # Managed boot diagnostics storage: serial console and screenshots without a storage account to secure.
  boot_diagnostics {}

  tags = var.tags
}
