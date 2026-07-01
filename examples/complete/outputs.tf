output "custom_table_ids" {
  description = "The custom log table ids."
  value       = module.log_analytics.custom_table_ids
}

output "sentinel_onboarding_ids" {
  description = "The Sentinel onboarding ids."
  value       = module.log_analytics.sentinel_onboarding_ids
}

output "solution_ids" {
  description = "The solution ids."
  value       = module.log_analytics.solution_ids
}

output "tags" {
  description = "The tags applied to the resources."
  value       = module.tags.tags
}

output "workspace_ids" {
  description = "Map of workspace name to resource id."
  value       = module.log_analytics.workspace_ids
}
