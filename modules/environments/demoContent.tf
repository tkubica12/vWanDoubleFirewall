resource "azurerm_subnet" "vms" {
  count                = var.deployDemo == "true" ? 1 : 0
  name                 = "internal"
  resource_group_name  = azurerm_resource_group.envRg.name
  virtual_network_name = azurerm_virtual_network.envVnet.name
  address_prefixes     = [var.vnetRange]
}

resource "azurerm_network_interface" "vm1" {
  count               = var.deployDemo == "true" ? 1 : 0
  name                = "${var.prefix}-${var.name}-vm1-nic"
  location            = azurerm_resource_group.envRg.location
  resource_group_name = azurerm_resource_group.envRg.name

  ip_configuration {
    name                          = "ipconfig"
    subnet_id                     = azurerm_subnet.vms[count.index].id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "random_string" "random" {
  length  = 16
  special = false
  lower   = true
  upper   = false
  number  = false
}
resource "azurerm_storage_account" "diag" {
  count                    = var.deployDemo == "true" ? 1 : 0
  name                     = "diag${random_string.random.id}"
  resource_group_name      = azurerm_resource_group.envRg.name
  location                 = azurerm_resource_group.envRg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_linux_virtual_machine" "vm1" {
  count                           = var.deployDemo == "true" ? 1 : 0
  name                            = "${var.prefix}-${var.name}-vm1"
  resource_group_name             = azurerm_resource_group.envRg.name
  location                        = azurerm_resource_group.envRg.location
  size                            = "Standard_B1s"
  admin_username                  = "tomas"
  admin_password                  = "Azure12345678"
  disable_password_authentication = false
  custom_data                     = "IyEvYmluL3NoCmFwdCB1cGRhdGUgJiYgYXB0IGluc3RhbGwgbmdpbnggLXk="

  network_interface_ids = [
    azurerm_network_interface.vm1[count.index].id,
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }

  boot_diagnostics {
    storage_account_uri = azurerm_storage_account.diag[count.index].primary_blob_endpoint
  }
}
