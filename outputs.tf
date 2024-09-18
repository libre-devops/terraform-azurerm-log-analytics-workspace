output "law_id" {
  description = "The  id of the log analytics workspace. If a new log analytic workspace is created, fetch its data id, if one is created, fetch the remote one instead"
  value       = azurerm_log_analytics_workspace.law.id
}

output "law_name" {
  value       = var.law_name
  description = "The name of the log analytics workspace"
}

output "law_primary_key" {
  description = "The primary key of the log analytics workspace. If a new log analytic workspace is created, fetch its data id, if one is created, fetch the remote one instead"
  value       = azurerm_log_analytics_workspace.law.primary_shared_key
}

output "law_secondary_key" {
  description = "The primary key of the log analytics workspace. If a new log analytic workspace is created, fetch its data id, if one is created, fetch the remote one instead"
  value       = azurerm_log_analytics_workspace.law.secondary_shared_key
}

output "law_workspace_id" {
  description = "The workspace id of the log analytics workspace. If a new log analytic workspace is created, fetch its data id, if one is created, fetch the remote one instead"
  value       = azurerm_log_analytics_workspace.law.workspace_id
}
