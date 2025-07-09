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
  client_id = "4cc6cbf3-3374-41df-b623-4ba071bb9b6c"
  client_secret = "q1e8Q~oE25-Eq2jj.nIYlFlxv7LYt6LXpQg54dwX"
  subscription_id = "420b6646-37ed-43f9-bc5e-f74001384aa8"  # From az account show
  tenant_id       = "2a144b72-f239-42d4-8c0e-6f0f17c48e33"  # From az account show
}



/* variable "client_id" {
  description = "Azure Client ID"
  type        = string
}

variable "client_secret" {
  description = "Azure Client Secret"
  type        = string
  sensitive   = true
}

variable "subscription_id" {
  description = "Azure Subscription ID"
  type        = string
}

variable "tenant_id" {
  description = "Azure Tenant ID"
  type        = string
} */