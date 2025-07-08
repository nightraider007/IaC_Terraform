#--------------------------------------------------
# Terraform Core Settings and Provider Requirements
#--------------------------------------------------

terraform {
  required_version = ">= 1.5.0"


  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.4.0"
    }
  }
}


#-------------------------
# Azure Provider Config
#-------------------------
provider "azurerm" {

  # The features block is mandatory for the azurerm provider, even if empty  
  features {
    resource_group {
        prevent_deletion_if_contains_resources = true
      }

  } # Mandatory for azurerm, even if empty


  # Avoid hardcoding credentials here in production — instead use environment variables or a secrets vault
  client_id       = var.client_id
  client_secret   = var.client_secret
  subscription_id = var.subscription_id
  tenant_id       = var.tenant_id
}


locals {
  # These values help enforce consistent tagging across resources
  default_tags = {
    environment = "dev"                  # Change as appropriate per environment (dev, test, prod)
    owner       = "infra-team"           # Ownership and accountability
    project     = "terraform-onboarding" # Useful for cost tracking and billing
  }
}



resource "azurerm_resource_group" "rg" {
  name     = "app-grp"
  location = "North Europe"
  tags     = local.default_tags   # Apply standard tagging from the locals block
}







#########################################################
# Outputs — Exposing Key Values After Apply
#########################################################

output "resource_group_name" {
  description = "Name of the resource group that was created"
  value       = azurerm_resource_group.rg.name
}

output "resource_group_location" {
  description = "Azure region of the deployed resource group"
  value       = azurerm_resource_group.rg.location
}
output "resource_group_id" {
  description = "Unique ID of the resource group"
  value       = azurerm_resource_group.rg.id
}
output "resource_group_tags" {
  description = "Tags applied to the resource group"
  value       = azurerm_resource_group.rg.tags
}
output "azurerm_client_id" {
  description = "Client ID used for authentication"
  value       = var.client_id
}
output "azurerm_subscription_id" {
  description = "Subscription ID used for the provider"
  value       = var.subscription_id
}
output "azurerm_tenant_id" {
  description = "Tenant ID used for the provider"
  value       = var.tenant_id
}
output "azurerm_client_secret" {
  description = "Client secret used for authentication"
  value       = var.client_secret
  sensitive   = true # Mark as sensitive to avoid showing in plain text
}
//output "azurerm_provider_version" {
  //description = "Version of the azurerm provider in use"
  //value       = azurerm.version
//}
output "azurerm_resource_group_id" {
  description = "ID of the resource group created"
  value       = azurerm_resource_group.rg.id
}
