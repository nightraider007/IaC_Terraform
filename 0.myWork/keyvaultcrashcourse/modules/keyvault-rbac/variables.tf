variable "name" { type = string }
variable "location" { type = string }
variable "resource_group_name" { type = string }
variable "tenant_id" { type = string }

variable "rbac_principal_id" { type = string }

variable "inject_secret" { type = bool }
variable "secret_name" { type = string }
variable "secret_value" { type = string }

variable "tags" { type = map(string) }