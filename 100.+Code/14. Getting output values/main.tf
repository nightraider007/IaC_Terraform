resource "azurerm_resource_group" "appgrp" {
  name     = "app-grp"
  location = local.resource_location
}

resource "azurerm_virtual_network" "app_network" {
  name                = local.virtual_network.name
  location            = local.resource_location
  resource_group_name = azurerm_resource_group.appgrp.name
  address_space       = local.virtual_network.address_prefixes 
}

resource "azurerm_subnet" "websubet01" {
  name                 = local.subnets[0].name
  resource_group_name  = azurerm_resource_group.appgrp.name
  virtual_network_name = azurerm_virtual_network.app_network.name
  address_prefixes     = local.subnets[0].address_prefixes
}

resource "azurerm_subnet" "appsubnet01" {
  name                 = local.subnets[1].name
  resource_group_name  = azurerm_resource_group.appgrp.name
  virtual_network_name = azurerm_virtual_network.app_network.name
  address_prefixes     = local.subnets[1].address_prefixes
}

resource "azurerm_network_interface" "webinterface01" {
  name                = "webinterface01"
  location            = local.resource_location
  resource_group_name = azurerm_resource_group.appgrp.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.websubet01.id
    private_ip_address_allocation = "Dynamic"
  }
}

output "websubet01_id" {
  value=azurerm_subnet.websubet01.id
}

