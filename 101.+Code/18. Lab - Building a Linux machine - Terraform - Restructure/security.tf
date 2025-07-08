data "azurerm_key_vault" "appvault300000" {
  name                = "appvault300000"
  resource_group_name = "security-grp"
}

resource "azurerm_key_vault_secret" "vmpassword" {
  name         = "vmpassword"
  value        = var.adminpassword
  key_vault_id = data.azurerm_key_vault.appvault300000.id
}