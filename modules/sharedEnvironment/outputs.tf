output "vwanHubId" {
  value = azurerm_virtual_hub.vwan.id
}

output "vwanRouteId" {
  value = azurerm_virtual_hub_route_table.vwan.id
}

output "externalFwIp" {
  value = azurerm_firewall.external.ip_configuration[0].private_ip_address
}

output "externalVnetName" {
  value = azurerm_virtual_network.internetVnet.name
}

output "externalVnetId" {
  value = azurerm_virtual_network.internetVnet.id
}

output "externalRgName" {
  value = azurerm_resource_group.sharedRg.name
}