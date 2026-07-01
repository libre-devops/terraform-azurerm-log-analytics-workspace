locals {
  location = lookup(var.regions, var.loc, "uksouth")
  rg_name  = "rg-${var.short}-${var.loc}-${terraform.workspace}-002"
  law_name = "log-${var.short}-${var.loc}-${terraform.workspace}-002"
}

module "tags" {
  source  = "libre-devops/tags/azurerm"
  version = "~> 4.0"

  environment     = "prd"
  cost_centre     = "1888/67"
  owner           = "platform@example.com"
  deployed_branch = var.deployed_branch
  deployed_repo   = var.deployed_repo
  additional_tags = { Application = "terraform-azurerm-log-analytics-workspace" }
}

module "rg" {
  source  = "libre-devops/rg/azurerm"
  version = "~> 4.0"

  resource_groups = [{ name = local.rg_name, location = local.location, tags = module.tags.tags }]
}

# Complete call: a workspace with a system-assigned identity, a bundled solution, a custom log table,
# and Microsoft Sentinel onboarding (via the onboarding resource, so no SecurityInsights solution).
module "log_analytics" {
  source = "../../"

  resource_group_id = module.rg.ids[local.rg_name]
  location          = local.location
  tags              = module.tags.tags

  log_analytics_workspaces = {
    (local.law_name) = {
      sku                             = "PerGB2018"
      retention_in_days               = 90
      daily_quota_gb                  = 5
      allow_resource_only_permissions = true
      internet_ingestion_enabled      = true
      internet_query_enabled          = true
      identity                        = { type = "SystemAssigned" }

      onboard_to_sentinel = true

      solutions = [
        { solution_name = "ContainerInsights", publisher = "Microsoft", product = "OMSGallery/ContainerInsights" },
        { solution_name = "VMInsights", publisher = "Microsoft", product = "OMSGallery/VMInsights" },
      ]

      custom_tables = [
        {
          name                    = "AppEvents_CL"
          display_name            = "Application events"
          description             = "Custom application event log."
          retention_in_days       = 30
          total_retention_in_days = 90
          columns = [
            { name = "TimeGenerated", type = "dateTime" },
            { name = "Message", type = "string", description = "The log message" },
            { name = "Severity", type = "string" },
            { name = "Count", type = "int" },
          ]
        }
      ]
    }
  }
}
