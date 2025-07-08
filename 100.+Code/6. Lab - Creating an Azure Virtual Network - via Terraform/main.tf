terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = "4.5.0"
    }
  }
}

provider "azurerm" {
  features {}
  client_id = "4cc6cbf3-3374-41df-b623-4ba071bb9b6c"
  client_secret = "q1e8Q~oE25-Eq2jj.nIYlFlxv7LYt6LXpQg54dwX"
  subscription_id = "420b6646-37ed-43f9-bc5e-f74001384aa8"  # From az account show
  tenant_id       = "2a144b72-f239-42d4-8c0e-6f0f17c48e33"  # From az account show
}

resource "azurerm_resource_group" "appgrp" {
  name     = "app-grp"
  location = "North Europe"
}

// https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_network

resource "azurerm_virtual_network" "app_network" {
  name                = "app-network"
  location            = azurerm_resource_group.appgrp.location 
  resource_group_name = azurerm_resource_group.appgrp.name
  address_space       = ["10.0.0.0/16"]

  subnet {
    name             = "websubnet01"
    address_prefixes = ["10.0.0.0/24"]
  }

  subnet {
    name             = "appsubnet01"
    address_prefixes = ["10.0.1.0/24"]
  }
 
}

