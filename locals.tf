locals {
  rg                  = provider::azurerm::parse_resource_id(var.resource_group_id)
  resource_group_name = local.rg.resource_group_name

  # Solution names that represent Microsoft Sentinel. Onboarding a workspace to Sentinel via the
  # onboarding resource is mutually exclusive with these solutions (enforced by a variable validation).
  sentinel_solution_names = ["SecurityInsights", "SecurityInsightsFree"]

  # Flatten each workspace's solutions to one map keyed by "<workspace>|<solution>", so they become
  # discrete azurerm_log_analytics_solution resources that reference their parent workspace by name.
  solutions = merge([
    for ws_name, ws in var.log_analytics_workspaces : {
      for sol in ws.solutions : "${ws_name}|${sol.solution_name}" => {
        workspace_name = ws_name
        solution_name  = sol.solution_name
        publisher      = sol.publisher
        product        = sol.product
        promotion_code = sol.promotion_code
      }
    }
  ]...)

  # Flatten custom log tables, keyed "<workspace>|<table>". Columns are sorted by name so a reordering
  # in the input does not churn the plan.
  custom_tables = merge([
    for ws_name, ws in var.log_analytics_workspaces : {
      for tbl in ws.custom_tables : "${ws_name}|${tbl.name}" => {
        workspace_name          = ws_name
        name                    = tbl.name
        description             = tbl.description
        display_name            = tbl.display_name
        plan                    = tbl.plan
        retention_in_days       = tbl.retention_in_days
        total_retention_in_days = tbl.total_retention_in_days
        columns                 = [for cn in sort([for c in tbl.columns : c.name]) : [for c in tbl.columns : c if c.name == cn][0]]
      }
    }
  ]...)

  # Workspaces that should be onboarded to Microsoft Sentinel via the onboarding resource.
  sentinel_workspaces = {
    for ws_name, ws in var.log_analytics_workspaces : ws_name => ws if ws.onboard_to_sentinel
  }
}
