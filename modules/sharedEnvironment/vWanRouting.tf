// Virtual WAN resource group
resource "azurerm_resource_group" "vwanRg" {
  name     = "${var.prefix}-vwan-rg"
  location = var.location
}

// Internet VNET
resource "azurerm_virtual_network" "internetVnet" {
  name                = "${var.prefix}-internet-vnet"
  location            = azurerm_resource_group.sharedRg.location
  resource_group_name = azurerm_resource_group.sharedRg.name
  address_space       = ["10.243.0.0/16"]

  subnet {
    name           = "AzureFirewallSubnet"
    address_prefix = "10.243.0.0/24"
  }
}

// Virtual WAN
resource "azurerm_virtual_wan" "vwan" {
  name                = "${var.prefix}-vwan"
  resource_group_name = azurerm_resource_group.vwanRg.name
  location            = azurerm_resource_group.vwanRg.location
}

resource "azurerm_virtual_hub" "vwan" {
  name                = "${var.prefix}-hub-${azurerm_resource_group.vwanRg.location}"
  resource_group_name = azurerm_resource_group.vwanRg.name
  location            = azurerm_resource_group.vwanRg.location
  virtual_wan_id      = azurerm_virtual_wan.vwan.id
  address_prefix      = "10.255.0.0/16"
  sku                 = "Standard"
}

// VWAN connection for internet VNET
resource "azurerm_virtual_hub_connection" "internetVnet" {
  name                      = "internetVnet-connection"
  virtual_hub_id            = azurerm_virtual_hub.vwan.id
  remote_virtual_network_id = azurerm_virtual_network.internetVnet.id
  internet_security_enabled = true

  routing {
    associated_route_table_id = azurerm_virtual_hub_route_table.vwanPrivateOnly.id
    static_vnet_route {
      address_prefixes    = ["0.0.0.0/0"]
      name                = "defaultViaExternalFw"
      next_hop_ip_address = azurerm_firewall.external.ip_configuration[0].private_ip_address
    }
  }
}

// Route private via internal Azure Firewall and public traffic via external Azure Firewall
resource "azurerm_virtual_hub_route_table" "vwan" {
  name           = "customRouteTable"
  virtual_hub_id = azurerm_virtual_hub.vwan.id

  // Send private traffic via hub firewall (specify firewall ID)
  route {
    name              = "private_traffic"
    destinations_type = "CIDR"
    destinations      = ["10.0.0.0/8"]
    next_hop_type     = "ResourceId"
    next_hop          = azurerm_firewall.internal.id
  }

  // Send public traffic via hub routing to external firewall by specifying internetVnet connection as resource ID
  route {
    name              = "public_traffic"
    destinations_type = "CIDR"
    destinations      = ["0.0.0.0/0"]
    next_hop_type     = "ResourceId"
    next_hop          = azurerm_virtual_hub_connection.internetVnet.id
  }
}

// Route private via internal Azure Firewall
resource "azurerm_virtual_hub_route_table" "vwanPrivateOnly" {
  name           = "customRouteTablePrivateOnly"
  virtual_hub_id = azurerm_virtual_hub.vwan.id

  // Send private traffic via hub firewall (specify firewall ID)
  route {
    name              = "private_traffic"
    destinations_type = "CIDR"
    destinations      = ["10.0.0.0/8"]
    next_hop_type     = "ResourceId"
    next_hop          = azurerm_firewall.internal.id
  }
}