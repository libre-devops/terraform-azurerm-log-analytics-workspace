variable "location" {
  description = "Azure region for the workspaces and their solutions."
  type        = string
}

variable "log_analytics_workspaces" {
  description = <<-EOT
    Log Analytics workspaces to create, keyed by workspace name. Each workspace may also declare
    solutions, custom log tables, and whether to onboard to Microsoft Sentinel.

    Sentinel: set onboard_to_sentinel = true to enable Sentinel via the onboarding resource. A workspace
    onboarded that way must NOT also list a SecurityInsights or SecurityInsightsFree solution (they
    conflict); use one path or the other.

    Custom table names must end in _CL, and each custom table needs at least one column.
  EOT
  type = map(object({
    sku                                     = optional(string, "PerGB2018")
    retention_in_days                       = optional(number, 30)
    daily_quota_gb                          = optional(number)
    allow_resource_only_permissions         = optional(bool, true)
    local_authentication_enabled            = optional(bool, true)
    cmk_for_query_forced                    = optional(bool)
    reservation_capacity_in_gb_per_day      = optional(number)
    internet_ingestion_enabled              = optional(bool, true)
    internet_query_enabled                  = optional(bool, true)
    data_collection_rule_id                 = optional(string)
    immediate_data_purge_on_30_days_enabled = optional(bool)

    identity = optional(object({
      type         = string
      identity_ids = optional(list(string), [])
    }))

    onboard_to_sentinel                   = optional(bool, false)
    sentinel_customer_managed_key_enabled = optional(bool, false)

    solutions = optional(list(object({
      solution_name  = string
      publisher      = string
      product        = string
      promotion_code = optional(string, "")
    })), [])

    custom_tables = optional(list(object({
      name                    = string
      description             = optional(string)
      display_name            = optional(string)
      plan                    = optional(string)
      retention_in_days       = optional(number)
      total_retention_in_days = optional(number)
      columns = list(object({
        name         = string
        type         = string
        description  = optional(string)
        display_name = optional(string)
      }))
    })), [])
  }))
  default = {}

  validation {
    condition     = alltrue([for ws in values(var.log_analytics_workspaces) : contains(["Free", "PerNode", "Premium", "Standard", "Standalone", "Unlimited", "CapacityReservation", "PerGB2018", "LACluster"], ws.sku)])
    error_message = "Each workspace sku must be a valid Log Analytics SKU (PerGB2018 is the modern default; CapacityReservation, Free, Standalone, etc.)."
  }

  validation {
    condition     = alltrue([for ws in values(var.log_analytics_workspaces) : ws.identity == null ? true : contains(["SystemAssigned", "UserAssigned", "SystemAssigned, UserAssigned"], ws.identity.type)])
    error_message = "identity.type must be SystemAssigned, UserAssigned, or \"SystemAssigned, UserAssigned\"."
  }

  validation {
    condition = alltrue([
      for ws in values(var.log_analytics_workspaces) : ws.onboard_to_sentinel ? !anytrue([
        for s in ws.solutions : contains(["SecurityInsights", "SecurityInsightsFree"], s.solution_name)
      ]) : true
    ])
    error_message = "A workspace onboarded to Sentinel (onboard_to_sentinel = true) must not also declare a SecurityInsights or SecurityInsightsFree solution; onboarding and the solution are mutually exclusive."
  }

  validation {
    condition = alltrue([
      for ws in values(var.log_analytics_workspaces) : alltrue([
        for t in ws.custom_tables : endswith(t.name, "_CL")
      ])
    ])
    error_message = "Custom log table names must end in _CL (Azure requirement for custom log tables)."
  }

  validation {
    condition = alltrue([
      for ws in values(var.log_analytics_workspaces) : alltrue([
        for t in ws.custom_tables : length(t.columns) > 0
      ])
    ])
    error_message = "Each custom table needs at least one column."
  }
}

variable "resource_group_id" {
  description = "Resource id of the resource group to create the workspaces in. The name and subscription are parsed from it (pass the rg module's ids output)."
  type        = string

  validation {
    condition     = try(provider::azurerm::parse_resource_id(var.resource_group_id).resource_type, "") == "resourceGroups"
    error_message = "resource_group_id must be a resource group id of the form /subscriptions/<sub>/resourceGroups/<name>."
  }
}

variable "tags" {
  description = "Tags to apply to the workspaces and solutions."
  type        = map(string)
  default     = {}
}
