data "azuread_users" "owners" {
  user_principal_names = var.owners
}

resource "azurerm_role_assignment" "owners" {
  for_each             = toset(data.azuread_users.owners.object_ids)
  scope                = azurerm_resource_group.envRg.id
  role_definition_name = "Owner"
  principal_id         = each.key
}
