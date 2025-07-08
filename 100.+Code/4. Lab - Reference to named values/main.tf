terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = "4.4.0"
    }
  }
}

provider "azurerm" {
  features {}
  client_id       = "4cc6cbf3-3374-41df-b623-4ba071bb9b6c"
  client_secret   = "q1e8Q~oE25-Eq2jj.nIYlFlxv7LYt6LXpQg54dwX"
  subscription_id = "420b6646-37ed-43f9-bc5e-f74001384aa8" # From az account show
  tenant_id       = "2a144b72-f239-42d4-8c0e-6f0f17c48e33" # From az account show
}

resource "azurerm_resource_group" "appgrp" {
  name     = "app-grp"
  location = "North Europe"
}

resource "azurerm_storage_account" "appstore400009078" {
  name                     = "appstore400009078heel"
  resource_group_name      = azurerm_resource_group.appgrp.name   
  location                 = azurerm_resource_group.appgrp.location
  account_tier             = "Standard"
  account_replication_type = "LRS"  
}

resource "azurerm_storage_container" "scripts" {
  name                  = "scripts"
  storage_account_name  = azurerm_storage_account.appstore400009078.name
}

resource "azurerm_storage_blob" "script01" {
  name                   = "script01.ps1"
  storage_account_name   = azurerm_storage_account.appstore400009078.name
  storage_container_name = azurerm_storage_container.scripts.name
  type                   = "Block"
  source                 = "script01.ps1"
}