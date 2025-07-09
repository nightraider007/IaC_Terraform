data "azurerm_client_config" "current" {}

# Only use this if the Key Vault already exists and you're NOT creating it with Terraform
 data "azurerm_key_vault" "appvault300000" {
   name                = "appvault300000"
  resource_group_name = "app-grp"
 }

resource "azurerm_key_vault" "appvault" {
  name                        = "appvault300000"   // e.g. "appstore400889078heeler"
  location                    = azurerm_resource_group.appgrp.location
  resource_group_name         = azurerm_resource_group.appgrp.name
  tenant_id                   = data.azurerm_client_config.current.tenant_id
  soft_delete_retention_days  = 7
  purge_protection_enabled    = false
  sku_name                    = "standard"
  enable_rbac_authorization   = true
}




resource "azurerm_key_vault_secret" "vmpassword" {
  name         = "vmpassword"
  value        = var.adminpassword
  key_vault_id = azurerm_key_vault.appvault.id
}