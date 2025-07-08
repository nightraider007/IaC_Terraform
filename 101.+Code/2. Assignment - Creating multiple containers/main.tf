resource "azurerm_resource_group" "appgrp" {
  name     = "app-grp"
  location = local.resource_location
}

resource "azurerm_storage_account" "storageaccount" {
  name                     = local.storage_account_name
  resource_group_name      = azurerm_resource_group.app-grp.name
  location                 = local.resource_location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_container" "scripts" {
  count=3
  name                  = "scripts${count.index}"
  storage_account_name  = azurerm_storage_account.storageaccount.name
}
# How do we get the output of the three containers
# We can use the splat operator

output "container-names" {
  value=azurerm_storage_container.scripts[*].name
}

