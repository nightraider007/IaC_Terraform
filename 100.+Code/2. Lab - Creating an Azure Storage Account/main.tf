terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = "4.4.0"
    }
  }
}

provider "azurerm" {

  features {} # Required even if left empty

  client_id = "4cc6cbf3-3374-41df-b623-4ba071bb9b6c"
  client_secret = "q1e8Q~oE25-Eq2jj.nIYlFlxv7LYt6LXpQg54dwX"
  subscription_id = "420b6646-37ed-43f9-bc5e-f74001384aa8"  # From az account show
  tenant_id       = "2a144b72-f239-42d4-8c0e-6f0f17c48e33"  # From az account show
}

locals {

  # Define any local variables here if needed
  # For example, you can define a variable for the resource group name
  resource_location = "North Europe"

  
}

//https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_group

resource "azurerm_resource_group" "appgrp" {
  name     = "app-grp"
  location = local.resource_location
}

// https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_account

resource "azurerm_storage_account" "appstore400009078heel" {
  name                     = "appstore400009078heel"
  resource_group_name      = azurerm_resource_group.appgrp.name
  location                 = azurerm_resource_group.appgrp.location
  account_kind             = "StorageV2"
  account_replication_type = "LRS"  
  account_tier             = "Standard"
  ##############################################################################
   
}