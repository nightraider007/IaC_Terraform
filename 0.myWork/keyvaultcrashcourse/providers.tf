data "azurerm_client_config" "current" {}
#--------------------------------------------------
# Terraform Core Settings and Provider Requirements
#--------------------------------------------------

terraform {
  required_version = ">= 1.8.0"


  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.4.0"
    }
  }
}


#-------------------------
# Azure Provider Configuration
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

