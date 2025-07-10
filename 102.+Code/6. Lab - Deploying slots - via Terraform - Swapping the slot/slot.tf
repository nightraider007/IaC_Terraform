resource "azurerm_windows_web_app_slot" "webapp_slot" {
  name           = var.webapp_slot[1]
  app_service_id = azurerm_windows_web_app.webapp["${var.webapp_slot[0]}"].id

  site_config {
    application_stack {
      current_stack="dotnet"
      dotnet_version="v8.0"
  }
  }
  depends_on = [ azurerm_service_plan.serviceplan ]
}

// https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/web_app_active_slot

resource "azurerm_web_app_active_slot" "activeslot" {
  slot_id = azurerm_windows_web_app_slot.webapp_slot.id

}