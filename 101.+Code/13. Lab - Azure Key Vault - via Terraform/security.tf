###############################
# 👤 Identity of Terraform User
###############################

data "azurerm_client_config" "current" {
  # This captures the Azure AD tenant ID and object ID of the authenticated user, service principal, or managed identity.
  # It’s useful when applying policies or permissions related to who’s executing the code.
}



##################################
# 🔐 Create the Azure Key Vault
##################################

resource "azurerm_key_vault" "appvault" {
  name                        = local.storageaccountname                    // Must be globally unique
  location                    = local.resource_location
  resource_group_name         = azurerm_resource_group.appgrp.name
  tenant_id                   = data.azurerm_client_config.current.tenant_id
  soft_delete_retention_days  = 7                                           // Retention for deleted secrets
  purge_protection_enabled    = false                                       // Can be true if strict deletion policies required
  sku_name                    = "standard"                          // Standard SKU is sufficient for most use cases
  
  # ✅ Enables RBAC instead of traditional access policies
  enable_rbac_authorization   = true
                           
}




resource "azurerm_role_assignment" "keyvault_rbac" {
  scope                = azurerm_key_vault.appvault.id
  role_definition_name = "Key Vault Secrets Officer"  # or "Key Vault Administrator"
  principal_id         = data.azurerm_client_config.current.object_id
}







########################################################################
# 🔑 Access Policy: Allow Terraform identity to manage Vault Secrets
########################################################################

/* resource "azurerm_key_vault_access_policy" "self_access" {
  key_vault_id = azurerm_key_vault.appvault.id

  tenant_id = data.azurerm_client_config.current.tenant_id
  object_id = data.azurerm_client_config.current.object_id

  secret_permissions = [
    "Get",    // Allow reading secrets
    "Set",    // Allow creating or updating secrets
    "List",   // Allow listing all secrets
    "Delete"  // Optional: allows deletion
  ]
} */

##############################################
# 🗝️ Secret: Store a password in the Key Vault
##############################################

resource "azurerm_key_vault_secret" "vmpassword" {
  name         = "vmpassword"                      // Name of the secret within the vault
  value        = "Azure@123"                       // This should ideally be from a sensitive variable
  key_vault_id = azurerm_key_vault.appvault.id     // Link to the vault just created
}
