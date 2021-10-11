// Deny creation of Public IP
resource "azurerm_policy_assignment" "denyResources" {
  name                 = "denyResources"
  scope                = azurerm_resource_group.envRg.id
  policy_definition_id = "/providers/Microsoft.Authorization/policyDefinitions/6c112d4e-5bc7-47ae-a041-ea2d9dccd749"
  description          = "Not allowed resource types"
  display_name         = "denyResources"
  location             = var.location

  parameters = <<PARAMETERS
{
  "listOfResourceTypesNotAllowed": {
    "value": [
        "Microsoft.Network/publicIPAddresses"
    ]
  }
}
PARAMETERS

}

