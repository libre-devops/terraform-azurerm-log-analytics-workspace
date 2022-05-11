output "law_id" {
  description = "The  id of the log analytics workspace. If a new log analytic workspace is created, fetch its data id, if one is created, fetch the remote one instead"
  value       = var.create_new_workspace == true ? data.azurerm_log_analytics_workspace.read_created_law.*.id : data.azurerm_log_analytics_workspace.read_law.*.id
}

output "law_name" {
  value       = var.law_name
  description = "The name of the log analytics workspace"
}

output "law_portal_url" {
  description = "The portla urlof the log analytics workspace. If a new log analytic workspace is created, fetch its data id, if one is created, fetch the remote one instead"

  value = var.create_new_workspace == true ? data.azurerm_log_analytics_workspace.read_created_law.*.portal_url : data.azurerm_log_analytics_workspace.read_law.*.portal_url
}

output "law_primary_key" {
  description = "The primary key of the log analytics workspace. If a new log analytic workspace is created, fetch its data id, if one is created, fetch the remote one instead"
  value       = var.create_new_workspace == true ? data.azurerm_log_analytics_workspace.read_created_law.*.primary_shared_key : data.azurerm_log_analytics_workspace.read_law.*.primary_shared_key
}

output "law_secondary_key" {
  description = "The primary key of the log analytics workspace. If a new log analytic workspace is created, fetch its data id, if one is created, fetch the remote one instead"
  value       = var.create_new_workspace == true ? data.azurerm_log_analytics_workspace.read_created_law.*.secondary_shared_key : data.azurerm_log_analytics_workspace.read_law.*.secondary_shared_key
}

output "law_workspace_id" {
  description = "The workspace id of the log analytics workspace. If a new log analytic workspace is created, fetch its data id, if one is created, fetch the remote one instead"
  value       = var.create_new_workspace == true ? data.azurerm_log_analytics_workspace.read_created_law.*.workspace_id : data.azurerm_log_analytics_workspace.read_law.*.workspace_id
}
