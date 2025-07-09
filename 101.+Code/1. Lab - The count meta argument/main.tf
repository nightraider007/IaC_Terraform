resource "azurerm_resource_group" "appgrp" {
  name     = "app-grp"
  location = local.resource_location

}

resource "azurerm_storage_account" "appstorageaccount" {
  count = 3
  name                     = "appstore${count.index}400009078heeel"
  resource_group_name      = azurerm_resource_group.appgrp.name
  location                 = "North Europe"
  account_tier             = "Standard"
  account_replication_type = "LRS"  
}

resource "azurerm_storage_container" "scripts" {
  count = 3
  name  = "scripts${count.index}"
  storage_account_name = azurerm_storage_account.appstorageaccount[count.index].name
  container_access_type = "private"
}
output "account_container_creation_status" {
  value = [
    for i in range(3) : "Created account: ${azurerm_storage_account.appstorageaccount[i].name}, container: ${azurerm_storage_container.scripts[i].name}"
  ]
}
