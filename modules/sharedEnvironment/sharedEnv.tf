// Shared resources resource group
resource "azurerm_resource_group" "sharedRg" {
  name     = "${var.prefix}-shared-rg"
  location = var.location
}

// Shared VNET
resource "azurerm_virtual_network" "sharedVnet" {
  name                = "${var.prefix}-shared-vnet"
  location            = azurerm_resource_group.sharedRg.location
  resource_group_name = azurerm_resource_group.sharedRg.name
  address_space       = ["10.244.0.0/16"]

  subnet {
    name           = "subnet1"
    address_prefix = "10.244.0.0/24"
  }
}

// VWAN connection for shared VNET
resource "azurerm_virtual_hub_connection" "sharedVnet" {
  name                      = "sharedVnet-connection"
  virtual_hub_id            = azurerm_virtual_hub.vwan.id
  remote_virtual_network_id = azurerm_virtual_network.sharedVnet.id
  internet_security_enabled = true

  routing {
    associated_route_table_id = azurerm_virtual_hub_route_table.vwan.id
  }
}



