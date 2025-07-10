

module "kv_rbac" {
  source              = "./modules/keyvault-rbac"

  name                = var.key_vault_name
  location            = var.location
  resource_group_name = var.resource_group
  tenant_id           = var.tenant_id

  rbac_principal_id   = var.rbac_principal_id

  inject_secret       = var.inject_secret
  secret_name         = var.secret_name
  secret_value        = var.secret_value

  tags                = var.project_tags
}