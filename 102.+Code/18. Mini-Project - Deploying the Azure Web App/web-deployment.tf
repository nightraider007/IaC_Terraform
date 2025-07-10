resource "azurerm_service_plan" "serviceplan" {
  for_each = var.app_environment.production.serviceplan
  name                = each.key
  resource_group_name = azurerm_resource_group.appgrp.name
  location            = local.resource_location
  os_type             = each.value.os_type
  sku_name            = each.value.sku
}

resource "azurerm_windows_web_app" "webapp" {
  for_each = var.app_environment.production.serviceapp
  name                = each.key
  resource_group_name = azurerm_resource_group.appgrp.name
  location            = local.resource_location
  
  service_plan_id     = azurerm_service_plan.serviceplan[each.value].id
  
  site_config {
        application_stack {
      current_stack="dotnet"
      dotnet_version="v8.0"
  }
  }

   connection_string {
    name  = "MySQLConnectionString"
    type  = "Custom"
    value = "Server=10.0.1.4;UserID=appusr;Password=Microsoft@123;Database=appdb"
  }

}


resource "azurerm_app_service_source_control" "appservice_sourcecontrol" {
  app_id   = azurerm_windows_web_app.webapp["webapp5550040030"].id
  repo_url = "https://github.com/cloudlearning4000/mysqlapp4000"
  branch   = "main"
  use_manual_integration = true  
}


