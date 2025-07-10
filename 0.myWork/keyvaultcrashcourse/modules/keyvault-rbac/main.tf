
resource "azurerm_resource_group" "this" {
  name = var.resource_group_name
  location = var.location
  lifecycle {
    prevent_destroy = true
  }
}
resource "azurerm_management_lock" "keep_rg" {
  name       = "do-not-delete"
  scope      = azurerm_resource_group.this.id
  lock_level = "CanNotDelete"
  notes      = "Keeps the RG alive for reused deployments."
}


resource "azurerm_key_vault" "this" {
  name                        = var.name
  location                    = var.location
  resource_group_name         = var.resource_group_name
  tenant_id                   = var.tenant_id
  sku_name                    = "standard"
  enable_rbac_authorization  = true
  tags                        = var.tags
}

resource "azurerm_role_assignment" "secrets_officer" {
  scope                = azurerm_key_vault.this.id
  role_definition_name = "Key Vault Secrets Officer"
  principal_id         = var.rbac_principal_id
}

resource "azurerm_role_assignment" "secrets_user" {
  scope                = azurerm_key_vault.this.id
  role_definition_name = "Key Vault Secrets User"
  principal_id         = var.rbac_principal_id
}

resource "azurerm_key_vault_secret" "optional_secret" {
  count        = var.inject_secret ? 1 : 0
  name         = var.secret_name
  value        = var.secret_value
  key_vault_id = azurerm_key_vault.this.id
}