resource "azurerm_resource_group" "rsg" {
  count    = var.deploy_az ? 1 : 0
  name     = "01_serverless"
  location = "UK West"
}

resource "azurerm_storage_account" "storage" {
  count                    = var.deploy_az ? 1 : 0
  name                     = "${var.project_name}fncstor"
  resource_group_name      = azurerm_resource_group.rsg[0].name
  location                 = azurerm_resource_group.rsg[0].location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_service_plan" "serverless_plan" {
  count               = var.deploy_az ? 1 : 0
  name                = "${var.project_name}plan"
  location            = azurerm_resource_group.rsg[0].location
  resource_group_name = azurerm_resource_group.rsg[0].name
  # kind                = "FunctionApp"
  # reserved            = true
  sku_name = "Y1"
  os_type  = "Windows"
}

resource "azurerm_windows_function_app" "sender" {
  count                      = var.deploy_az && var.az_send ? 1 : 0
  name                       = "${var.project_name}-sender"
  location                   = azurerm_resource_group.rsg[0].location
  resource_group_name        = azurerm_resource_group.rsg[0].name
  service_plan_id            = azurerm_service_plan.serverless_plan[0].id
  storage_account_name       = azurerm_storage_account.storage[0].name
  storage_account_access_key = azurerm_storage_account.storage[0].primary_access_key

  https_only                  = true
  functions_extension_version = "~4"

  site_config {

    application_stack {
      dotnet_version = "v6.0"
    }
  }

  app_settings = {
    "RECEIVERADDR"             = var.az_receive ? "https://${azurerm_windows_function_app.receiver[0].default_hostname}/api/receiver?code=${data.azurerm_function_app_host_keys.receiver[0].default_function_key}" : google_cloudfunctions_function.receiver[0].https_trigger_url
    "WEBSITE_RUN_FROM_PACKAGE" = 1
  }
}

resource "azurerm_windows_function_app" "receiver" {
  count                      = var.deploy_az && var.az_receive ? 1 : 0
  name                       = "${var.project_name}-receiver"
  location                   = azurerm_resource_group.rsg[0].location
  resource_group_name        = azurerm_resource_group.rsg[0].name
  service_plan_id            = azurerm_service_plan.serverless_plan[0].id
  storage_account_name       = azurerm_storage_account.storage[0].name
  storage_account_access_key = azurerm_storage_account.storage[0].primary_access_key

  https_only                  = true
  functions_extension_version = "~4"

  site_config {

    application_stack {
      dotnet_version = "v6.0"
    }
  }

  app_settings = {
    "WEBSITE_RUN_FROM_PACKAGE" = 1
  }
}

data "azurerm_function_app_host_keys" "receiver" {
  count               = var.deploy_az && var.az_receive ? 1 : 0
  name                = azurerm_windows_function_app.receiver[0].name
  resource_group_name = azurerm_resource_group.rsg[0].name
}
