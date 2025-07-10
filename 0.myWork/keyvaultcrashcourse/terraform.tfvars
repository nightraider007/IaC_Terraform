# secrets.auto.tfvars
client_id        = "4cc6cbf3-3374-41df-b623-4ba071bb9b6c"
client_secret    = "q1e8Q~oE25-Eq2jj.nIYlFlxv7LYt6LXpQg54dwX"
subscription_id  = "420b6646-37ed-43f9-bc5e-f74001384aa8"
tenant_id        = "2a144b72-f239-42d4-8c0e-6f0f17c48e33"
rbac_principal_id = "4cc6cbf3-3374-41df-b623-4ba071bb9b6c" # (can match client_id or SP object_id)
inject_secret     = true
secret_name       = "adminPassword"
secret_value      = "SuperSecure123!"
location          = "uksouth"
resource_group    = "rg-keyvolt-plat-dev"
key_vault_name    = "my-key-volt-dev"
project_tags = {
  owner      = "Tox OG"
  environment = "dev"
}
