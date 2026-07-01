# Plan-time tests for the module. The azurerm provider is mocked, so no credentials, no
# features block, and no cloud calls are needed:
#   terraform init -backend=false && terraform test

mock_provider "azurerm" {}

variables {
  resource_group_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-ldo-uks-tst-001"
  location          = "uksouth"

  log_analytics_workspaces = {
    "log-ldo-uks-tst-001" = {
      sku               = "PerGB2018"
      retention_in_days = 30
    }
  }
}

run "creates_workspace_with_secure_defaults" {
  command = plan

  assert {
    condition     = azurerm_log_analytics_workspace.this["log-ldo-uks-tst-001"].allow_resource_only_permissions == true
    error_message = "allow_resource_only_permissions should default to true."
  }

  assert {
    condition     = output.resource_group_name == "rg-ldo-uks-tst-001"
    error_message = "resource_group_name should be parsed from resource_group_id."
  }
}

run "bundles_solutions_tables_and_sentinel" {
  command = plan

  variables {
    log_analytics_workspaces = {
      "log-ldo-uks-tst-002" = {
        onboard_to_sentinel = true
        solutions = [
          { solution_name = "ContainerInsights", publisher = "Microsoft", product = "OMSGallery/ContainerInsights" }
        ]
        custom_tables = [
          {
            name    = "MyApp_CL"
            columns = [{ name = "Message", type = "string" }, { name = "TimeGenerated", type = "dateTime" }]
          }
        ]
      }
    }
  }

  assert {
    condition     = length(azurerm_log_analytics_solution.this) == 1 && length(azurerm_log_analytics_workspace_table_custom_log.this) == 1 && length(azurerm_sentinel_log_analytics_workspace_onboarding.this) == 1
    error_message = "A solution, a custom table, and a Sentinel onboarding should each be created."
  }
}

run "rejects_sentinel_with_security_insights_solution" {
  command = plan

  variables {
    log_analytics_workspaces = {
      "log-ldo-uks-tst-003" = {
        onboard_to_sentinel = true
        solutions           = [{ solution_name = "SecurityInsights", publisher = "Microsoft", product = "OMSGallery/SecurityInsights" }]
      }
    }
  }

  expect_failures = [var.log_analytics_workspaces]
}

run "rejects_custom_table_without_cl_suffix" {
  command = plan

  variables {
    log_analytics_workspaces = {
      "log-ldo-uks-tst-004" = {
        custom_tables = [{ name = "MyApp", columns = [{ name = "Message", type = "string" }] }]
      }
    }
  }

  expect_failures = [var.log_analytics_workspaces]
}

run "rejects_invalid_sku" {
  command = plan

  variables {
    log_analytics_workspaces = {
      "log-ldo-uks-tst-005" = { sku = "SuperDuper" }
    }
  }

  expect_failures = [var.log_analytics_workspaces]
}
