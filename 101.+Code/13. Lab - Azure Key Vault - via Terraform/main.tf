resource "azurerm_resource_group" "appgrp" {
  name     = "app-grp"
  location = local.resource_location
}


output "terraform_identity" {
  value = {
    client_id = data.azurerm_client_config.current.client_id
    object_id = data.azurerm_client_config.current.object_id
    tenant_id = data.azurerm_client_config.current.tenant_id
  }
}


