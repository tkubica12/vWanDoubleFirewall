// External Azure Firewall
resource "azurerm_public_ip" "fw-external" {
  name                = "${var.prefix}-fw-external-ip"
  resource_group_name = azurerm_resource_group.sharedRg.name
  location            = azurerm_resource_group.sharedRg.location
  allocation_method   = "Static"
  sku                 = "Standard"
}
resource "azurerm_firewall_policy" "external" {
  name                = "${var.prefix}-fw-external-policy"
  resource_group_name = azurerm_resource_group.sharedRg.name
  location            = azurerm_resource_group.sharedRg.location
}

resource "azurerm_firewall" "external" {
  name                = "${var.prefix}-fw-external"
  location            = azurerm_resource_group.sharedRg.location
  resource_group_name = azurerm_resource_group.sharedRg.name
  sku_name            = "AZFW_VNet"
  sku_tier            = "Premium"
  threat_intel_mode   = ""
  firewall_policy_id  = azurerm_firewall_policy.external.id
  zones               = ["1", "2", "3"]

  ip_configuration {
    name                 = "fw"
    subnet_id            = "${azurerm_virtual_network.internetVnet.id}/subnets/AzureFirewallSubnet"
    public_ip_address_id = azurerm_public_ip.fw-external.id
  }
}

// Outbound FQDNs for environments
resource "azurerm_firewall_policy_rule_collection_group" "outboundFqdns" {
  name               = "outboundFqdns"
  firewall_policy_id = azurerm_firewall_policy.external.id
  priority           = 200

  dynamic "application_rule_collection" {
    for_each = yamldecode(file("./environments.yaml"))
    content {

      name     = application_rule_collection.key
      priority = application_rule_collection.value.fwPriority
      action   = "Allow"

      dynamic "rule" {
        for_each = application_rule_collection.value.outboundFqdns
        content {
          name = rule.value.name

          source_ip_groups = [
            azurerm_ip_group.vwan[application_rule_collection.key].id
          ]

          destination_fqdns = rule.value.fqdns

          protocols {
            port = "443"
            type = "Https"
          }
        }
      }
    }
  }
}

// Common outbound FQDNs
resource "azurerm_firewall_policy_rule_collection_group" "commonFqdns" {
  name               = "commonFqdns"
  firewall_policy_id = azurerm_firewall_policy.external.id
  priority           = 100

  application_rule_collection {
    name     = "commonFqdns"
    priority = 100
    action   = "Allow"

    rule {
      name = "AzureTags"
      protocols {
        type = "Https"
        port = 443
      }
      source_addresses = ["10.0.0.0/8"]

      destination_fqdn_tags = [
        "AzureBackup",
        "AzureKubernetesService",
        "HDInsight",
        "MicrosoftActiveProtectionService",
        "WindowsDiagnostics",
        "WindowsUpdate",
      ]
    }

    rule {
      name = "company"
      protocols {
        type = "Https"
        port = 443
      }
      source_addresses = ["10.0.0.0/8"]

      destination_fqdns = [
        "company.com",
        "*.company.com",
      ]
    }

    rule {
      name = "Ubuntu"
      protocols {
        type = "Https"
        port = 443
      }
      protocols {
        type = "Http"
        port = 80
      }
      source_addresses = ["10.0.0.0/8"]

      destination_fqdns = [
        "ubuntu.com",
        "*.ubuntu.com",
      ]
    }
  }
}
