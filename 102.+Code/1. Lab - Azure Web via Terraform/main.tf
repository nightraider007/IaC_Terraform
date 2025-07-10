resource "azurerm_resource_group" "appgrp" {
  name     = "app-grp"
  location = local.resource_location
}

//https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/service_plan

resource "azurerm_service_plan" "serviceplan" {
  for_each = var.webapp_environment.production.serviceplan
  name                = each.key
  resource_group_name = azurerm_resource_group.appgrp.name
  location            = local.resource_location
  os_type             = each.value.os_type
  sku_name            = each.value.sku
}

// https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/windows_web_app
resource "azurerm_windows_web_app" "webapp" {
  for_each = var.webapp_environment.production.serviceapp
  name                = each.key
  resource_group_name = azurerm_resource_group.appgrp.name
  location            = local.resource_location
  service_plan_id     = azurerm_service_plan.serviceplan[each.value].id
  
  site_config {
    always_on=false
     
    application_stack {
      current_stack="dotnet"
      dotnet_version="v8.0"
  }
  }  
}