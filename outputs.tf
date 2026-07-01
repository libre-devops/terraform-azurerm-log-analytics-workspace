output "custom_table_ids" {
  description = "Map of \"<workspace>|<table>\" to the custom log table id."
  value       = { for k, t in azurerm_log_analytics_workspace_table_custom_log.this : k => t.id }
}

output "identity_principal_ids" {
  description = "Map of workspace name to its system-assigned identity principal id (only for workspaces with an identity)."
  value       = { for k, w in azurerm_log_analytics_workspace.this : k => try(w.identity[0].principal_id, null) }
}

output "primary_shared_keys" {
  description = "Map of workspace name to its primary shared key."
  value       = { for k, w in azurerm_log_analytics_workspace.this : k => w.primary_shared_key }
  sensitive   = true
}

output "resource_group_name" {
  description = "Resource group name parsed from resource_group_id."
  value       = local.resource_group_name
}

output "secondary_shared_keys" {
  description = "Map of workspace name to its secondary shared key."
  value       = { for k, w in azurerm_log_analytics_workspace.this : k => w.secondary_shared_key }
  sensitive   = true
}

output "sentinel_onboarding_ids" {
  description = "Map of workspace name to its Sentinel onboarding id (only onboarded workspaces)."
  value       = { for k, o in azurerm_sentinel_log_analytics_workspace_onboarding.this : k => o.id }
}

output "solution_ids" {
  description = "Map of \"<workspace>|<solution>\" to the solution id."
  value       = { for k, s in azurerm_log_analytics_solution.this : k => s.id }
}

output "subscription_id" {
  description = "Subscription id parsed from resource_group_id."
  value       = local.rg.subscription_id
}

output "tags" {
  description = "The tags applied to the workspaces."
  value       = var.tags
}

output "workspace_guids" {
  description = "Map of workspace name to its workspace (customer) id GUID."
  value       = { for k, w in azurerm_log_analytics_workspace.this : k => w.workspace_id }
}

output "workspace_ids" {
  description = "Map of workspace name to its resource id."
  value       = { for k, w in azurerm_log_analytics_workspace.this : k => w.id }
}

output "workspace_ids_zipmap" {
  description = "Map of workspace name to a { name, id } object, for passing where both are needed together."
  value       = { for k, w in azurerm_log_analytics_workspace.this : k => { name = w.name, id = w.id } }
}

output "workspace_names" {
  description = "The workspace names."
  value       = keys(azurerm_log_analytics_workspace.this)
}
