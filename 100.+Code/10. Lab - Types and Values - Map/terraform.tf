terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = "4.5.0"
    }
  }
}

provider "azurerm" {

  features {} # Required even if left empty

  client_id = var.client_id
  client_secret = var.client_secret
  subscription_id = var.subscription_id  # From az account show
  tenant_id       =   var.tenant_id  # From az account show
}

