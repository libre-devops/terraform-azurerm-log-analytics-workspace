resource "azurerm_log_analytics_workspace" "law" {
  count                              = try(var.create_new_workspace, null) == true ? 1 : 0
  name                               = try(var.law_name, null)
  location                           = var.location
  resource_group_name                = var.rg_name
  sku                                = title(try(var.law_sku, null))
  retention_in_days                  = try(var.retention_in_days, null)
  reservation_capacity_in_gb_per_day = var.law_sku == "CapacityReservation" ? var.reservation_capacity_in_gb_per_day : null
  daily_quota_gb                     = try(var.daily_quota_gb, null)
  internet_ingestion_enabled         = try(var.internet_ingestion_enabled, null)
  internet_query_enabled             = try(var.internet_query_enabled, null)
  tags                               = try(var.tags, null)
}

data "azurerm_log_analytics_workspace" "read_created_law" {
  count               = try(var.create_new_workspace, null) == true ? 1 : 0
  name                = azurerm_log_analytics_workspace.law.name
  resource_group_name = var.rg_name
}

data "azurerm_log_analytics_workspace" "read_law" {
  count               = try(var.create_new_workspace, null) == false ? 1 : 0
  name                = var.law_name
  resource_group_name = var.rg_name
}