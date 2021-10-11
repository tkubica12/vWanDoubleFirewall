// IP groups representing each environment
resource "azurerm_ip_group" "vwan" {
  for_each            = yamldecode(file("./environments.yaml"))
  name                = "${each.key}-ipgroup"
  location            = azurerm_resource_group.vwanRg.location
  resource_group_name = azurerm_resource_group.vwanRg.name
  cidrs               = [each.value.vnetRange]
}

// IP groups representing shared environment
resource "azurerm_ip_group" "shared" {
  name                = "sharedenv-ipgroup"
  location            = azurerm_resource_group.vwanRg.location
  resource_group_name = azurerm_resource_group.vwanRg.name
  cidrs               = azurerm_virtual_network.sharedVnet.address_space
}