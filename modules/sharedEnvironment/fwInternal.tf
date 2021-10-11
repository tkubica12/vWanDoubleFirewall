// Internal Azure Firewall
resource "azurerm_firewall_policy" "internal" {
  name                = "${var.prefix}-fw-internal-policy"
  resource_group_name = azurerm_resource_group.vwanRg.name
  location            = azurerm_resource_group.vwanRg.location
}

resource "azurerm_firewall" "internal" {
  name                = "${var.prefix}-fw-internal"
  location            = azurerm_resource_group.vwanRg.location
  resource_group_name = azurerm_resource_group.vwanRg.name
  sku_name            = "AZFW_Hub"
  sku_tier            = "Premium"
  threat_intel_mode   = ""
  firewall_policy_id  = azurerm_firewall_policy.internal.id
  zones               = ["1", "2", "3"]

  virtual_hub {
    virtual_hub_id  = azurerm_virtual_hub.vwan.id
    public_ip_count = 1
  }
}

