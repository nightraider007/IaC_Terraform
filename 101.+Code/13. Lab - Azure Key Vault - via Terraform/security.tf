resource "azurerm_key_vault" "appvault700089999" {
  name                        = "appvault700089999"
  location                    = local.resource_location
  resource_group_name         = azurerm_resource_group.appgrp.name
  tenant_id                   = "38dbefc3-d57f-4955-b62c-1406e16a4ea8"
  soft_delete_retention_days  = 7
  purge_protection_enabled    = false
  sku_name = "standard"
  
}