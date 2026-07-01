# Log Analytics workspaces (keyed by name) plus the things that earn this module its keep: bundled
# solutions, custom log tables, and Microsoft Sentinel onboarding, all scoped to their parent
# workspace. Sentinel is enabled via azurerm_sentinel_log_analytics_workspace_onboarding; a workspace
# onboarded that way must NOT also declare a SecurityInsights/SecurityInsightsFree solution (they
# conflict), which a variable validation enforces. The resource group is passed by id and parsed.

resource "azurerm_log_analytics_workspace" "this" {
  for_each = var.log_analytics_workspaces

  resource_group_name = local.resource_group_name
  location            = var.location
  tags                = var.tags

  name                                    = each.key
  sku                                     = each.value.sku
  retention_in_days                       = each.value.retention_in_days
  daily_quota_gb                          = each.value.daily_quota_gb
  allow_resource_only_permissions         = each.value.allow_resource_only_permissions
  local_authentication_enabled            = each.value.local_authentication_enabled
  cmk_for_query_forced                    = each.value.cmk_for_query_forced
  reservation_capacity_in_gb_per_day      = each.value.reservation_capacity_in_gb_per_day
  internet_ingestion_enabled              = each.value.internet_ingestion_enabled
  internet_query_enabled                  = each.value.internet_query_enabled
  data_collection_rule_id                 = each.value.data_collection_rule_id
  immediate_data_purge_on_30_days_enabled = each.value.immediate_data_purge_on_30_days_enabled

  dynamic "identity" {
    for_each = each.value.identity != null ? [each.value.identity] : []

    content {
      type         = identity.value.type
      identity_ids = identity.value.identity_ids
    }
  }
}

resource "azurerm_sentinel_log_analytics_workspace_onboarding" "this" {
  for_each = local.sentinel_workspaces

  workspace_id                 = azurerm_log_analytics_workspace.this[each.key].id
  customer_managed_key_enabled = each.value.sentinel_customer_managed_key_enabled
}

resource "azurerm_log_analytics_solution" "this" {
  for_each = local.solutions

  resource_group_name = local.resource_group_name
  location            = var.location
  tags                = var.tags

  solution_name         = each.value.solution_name
  workspace_resource_id = azurerm_log_analytics_workspace.this[each.value.workspace_name].id
  workspace_name        = azurerm_log_analytics_workspace.this[each.value.workspace_name].name

  plan {
    publisher      = each.value.publisher
    product        = each.value.product
    promotion_code = each.value.promotion_code
  }
}

resource "azurerm_log_analytics_workspace_table_custom_log" "this" {
  for_each = local.custom_tables

  name                    = each.value.name
  workspace_id            = azurerm_log_analytics_workspace.this[each.value.workspace_name].id
  description             = each.value.description
  display_name            = each.value.display_name
  plan                    = each.value.plan
  retention_in_days       = each.value.retention_in_days
  total_retention_in_days = each.value.total_retention_in_days

  dynamic "column" {
    for_each = each.value.columns

    content {
      name         = column.value.name
      type         = column.value.type
      description  = column.value.description
      display_name = column.value.display_name
    }
  }
}
