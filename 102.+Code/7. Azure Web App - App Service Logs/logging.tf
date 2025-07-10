resource "azurerm_storage_account" "appstore40099349" {
  name                     = "appstore40099349"
  resource_group_name      = azurerm_resource_group.appgrp.name
  location                 = local.resource_location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  account_kind = "StorageV2"  
  
}

resource "azurerm_storage_container" "weblogs" {
  name                  = "weblogs"
  storage_account_name  = azurerm_storage_account.appstore40099349.name
  container_access_type = "blob"
}

// https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/storage_account_blob_container_sas

data "azurerm_storage_account_blob_container_sas" "accountsas" {
  connection_string = azurerm_storage_account.appstore40099349.primary_connection_string
  container_name=azurerm_storage_container.weblogs.name
  https_only        = true  
  
  start  = "2024-10-01"
  expiry = "2024-10-30"

  permissions {
    read   = true
    add    = true
    create = false
    write  = true
    delete = true
    list   = true
  }
  
}