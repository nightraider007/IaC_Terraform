variable "client_id"       { type = string }
variable "client_secret"   { type = string }
variable "subscription_id" { type = string }
variable "tenant_id"       { type = string }

variable "key_vault_name"     { type = string }
variable "location"           { type = string }
variable "resource_group"     { type = string }
variable "rbac_principal_id"  { type = string }

variable "inject_secret"      { type = bool }
variable "secret_name"        { type = string }
variable "secret_value"       { type = string }

variable "project_tags"       { type = map(string) }