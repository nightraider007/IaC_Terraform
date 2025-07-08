resource "azurerm_resource_group" "appgrp" {
  name     = "app-grp"
  location = local.resource_location
}

resource "azurerm_storage_account" "appstorageaccount" {
  name                     = local.storageaccountname
  resource_group_name      = azurerm_resource_group.appgrp.name
  location                 = local.resource_location
  account_tier             = "Standard"
  account_replication_type = "LRS"  
}

resource "azurerm_storage_container" "scripts" {
  for_each = toset([ "data","scripts","logs" ])
  name                  = each.key
  storage_account_name  = azurerm_storage_account.appstorageaccount.name
}

resource "azurerm_storage_blob" "scripts" {
  for_each = tomap(
  {   script01="script01.ps1"
      script02="script02.ps1"
      script03="script03.ps1"
    })
  name                   = "${each.key}.ps1"
  storage_account_name   = azurerm_storage_account.appstorageaccount.name
  storage_container_name = azurerm_storage_container.scripts["scripts"].name
  type                   = "Block"
  source                 = each.value
}


