<!--
  Keep the title and badges OUTSIDE the centered <div>: the Terraform Registry's markdown renderer
  does not parse markdown inside an HTML block, so a # heading or [![badge]] in the div renders as
  literal text on the registry. Only the logo (HTML) goes in the div.
-->
<div align="center">
  <a href="https://libredevops.org">
    <picture>
      <source media="(prefers-color-scheme: dark)" srcset="https://libredevops.org/assets/libre-devops-white.png">
      <img alt="Libre DevOps" src="https://libredevops.org/assets/libre-devops-black.png" width="300">
    </picture>
  </a>
</div>

# Terraform Azure Log Analytics Workspace

Log Analytics workspaces plus their solutions, custom log tables, and Microsoft Sentinel onboarding.

[![CI](https://github.com/libre-devops/terraform-azurerm-log-analytics-workspace/actions/workflows/ci.yml/badge.svg)](https://github.com/libre-devops/terraform-azurerm-log-analytics-workspace/actions/workflows/ci.yml)
[![Release](https://img.shields.io/github/v/release/libre-devops/terraform-azurerm-log-analytics-workspace?sort=semver&label=release)](https://github.com/libre-devops/terraform-azurerm-log-analytics-workspace/releases/latest)
[![Terraform Registry](https://img.shields.io/badge/registry-libre--devops-7B42BC?logo=terraform&logoColor=white)](https://registry.terraform.io/namespaces/libre-devops)
[![License](https://img.shields.io/github/license/libre-devops/terraform-azurerm-log-analytics-workspace)](./LICENSE)

---

## Overview

Log Analytics workspaces keyed by name, and the pieces that make this more than a workspace wrapper:
per-workspace **solutions**, **custom log tables** (columns sorted for a stable plan), and **Microsoft
Sentinel onboarding**. Sentinel is enabled through `azurerm_sentinel_log_analytics_workspace_onboarding`;
a workspace onboarded that way must not also declare a `SecurityInsights`/`SecurityInsightsFree`
solution (they conflict), which a validation enforces. Custom table names must end in `_CL`. The
resource group is passed by id and parsed; identities (system- and/or user-assigned) are supported.
(This module supersedes the separate `log-analytics-solution` module, which is archived.)

## Usage

```hcl
module "log_analytics" {
  source  = "libre-devops/log-analytics-workspace/azurerm"
  version = "~> 4.0"

  resource_group_id = module.rg.ids["rg-ldo-uks-prd-001"]
  location          = "uksouth"
  tags              = module.tags.tags

  log_analytics_workspaces = {
    "log-ldo-uks-prd-001" = {
      sku                 = "PerGB2018"
      retention_in_days   = 90
      onboard_to_sentinel = true
      identity            = { type = "SystemAssigned" }

      solutions = [
        { solution_name = "ContainerInsights", publisher = "Microsoft", product = "OMSGallery/ContainerInsights" }
      ]

      custom_tables = [
        {
          name    = "MyApp_CL"
          columns = [{ name = "TimeGenerated", type = "dateTime" }, { name = "Message", type = "string" }]
        }
      ]
    }
  }
}
```

## Examples

- [`examples/minimal`](./examples/minimal) - a single workspace with defaults.
- [`examples/complete`](./examples/complete) - a workspace with a system-assigned identity, a solution,
  a custom log table, and Sentinel onboarding.

## Developing

Local work needs **PowerShell 7+** and **[`just`](https://github.com/casey/just)**, because the recipes
wrap the [LibreDevOpsHelpers](https://www.powershellgallery.com/packages/LibreDevOpsHelpers)
PowerShell module (the same engine the `libre-devops/terraform-azure` action runs in CI). Install
just with `brew install just`, or `uv tool add rust-just` then `uv run just <recipe>`.

Run `just` to list recipes: `just update-ldo-pwsh` (install or force-update LibreDevOpsHelpers from
PSGallery), `just validate`, `just scan` (Trivy only), `just pwsh-analyze` (PSScriptAnalyzer only),
`just plan`, `just apply`, `just destroy`, `just e2e`, `just test`, and `just docs` (the
plan/apply/destroy recipes mirror the action, including the storage firewall dance; `just e2e`
applies an example then always destroys it, defaulting to `minimal`, so nothing is left running).
Releasing is also `just`:
`just increment-release [patch|minor|major]` bumps, tags, and publishes a GitHub release, and the
Terraform Registry picks up the tag.

## Security scan exceptions

This module is scanned with [Trivy](https://github.com/aquasecurity/trivy); HIGH and CRITICAL
findings fail the build. Any waiver is a deliberate, reviewed decision, never a way to quiet a
finding that should be fixed. Waivers live in [`.trivyignore.yaml`](./.trivyignore.yaml) (the
machine-applied source of truth, passed to Trivy with `--ignorefile`) and are mirrored in the table
below so the reason is auditable.

| Trivy ID | Resource | Finding | Justification |
|----------|----------|---------|---------------|
| _None_   |          |         |               |

To add an exception: add an entry to `.trivyignore.yaml` (`id`, optional `paths` to scope it, and a
`statement` recording why), then add a matching row here. Where the finding is out of this module's
scope, point the justification at the Libre DevOps module that does address it (for example the
private-endpoint module). Both the file and this table are reviewed in the pull request.

## Reference

The Requirements, Providers, Inputs, Outputs, and Resources below are generated by `terraform-docs`.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.9.0, < 2.0.0 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | >= 4.0.0, < 5.0.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | >= 4.0.0, < 5.0.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [azurerm_log_analytics_solution.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/log_analytics_solution) | resource |
| [azurerm_log_analytics_workspace.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/log_analytics_workspace) | resource |
| [azurerm_log_analytics_workspace_table_custom_log.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/log_analytics_workspace_table_custom_log) | resource |
| [azurerm_sentinel_log_analytics_workspace_onboarding.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/sentinel_log_analytics_workspace_onboarding) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_location"></a> [location](#input\_location) | Azure region for the workspaces and their solutions. | `string` | n/a | yes |
| <a name="input_log_analytics_workspaces"></a> [log\_analytics\_workspaces](#input\_log\_analytics\_workspaces) | Log Analytics workspaces to create, keyed by workspace name. Each workspace may also declare<br/>solutions, custom log tables, and whether to onboard to Microsoft Sentinel.<br/><br/>Sentinel: set onboard\_to\_sentinel = true to enable Sentinel via the onboarding resource. A workspace<br/>onboarded that way must NOT also list a SecurityInsights or SecurityInsightsFree solution (they<br/>conflict); use one path or the other.<br/><br/>Custom table names must end in \_CL, and each custom table needs at least one column. | <pre>map(object({<br/>    sku                                     = optional(string, "PerGB2018")<br/>    retention_in_days                       = optional(number, 30)<br/>    daily_quota_gb                          = optional(number)<br/>    allow_resource_only_permissions         = optional(bool, true)<br/>    local_authentication_enabled            = optional(bool, true)<br/>    cmk_for_query_forced                    = optional(bool)<br/>    reservation_capacity_in_gb_per_day      = optional(number)<br/>    internet_ingestion_enabled              = optional(bool, true)<br/>    internet_query_enabled                  = optional(bool, true)<br/>    data_collection_rule_id                 = optional(string)<br/>    immediate_data_purge_on_30_days_enabled = optional(bool)<br/><br/>    identity = optional(object({<br/>      type         = string<br/>      identity_ids = optional(list(string), [])<br/>    }))<br/><br/>    onboard_to_sentinel                   = optional(bool, false)<br/>    sentinel_customer_managed_key_enabled = optional(bool, false)<br/><br/>    solutions = optional(list(object({<br/>      solution_name  = string<br/>      publisher      = string<br/>      product        = string<br/>      promotion_code = optional(string, "")<br/>    })), [])<br/><br/>    custom_tables = optional(list(object({<br/>      name                    = string<br/>      description             = optional(string)<br/>      display_name            = optional(string)<br/>      plan                    = optional(string)<br/>      retention_in_days       = optional(number)<br/>      total_retention_in_days = optional(number)<br/>      columns = list(object({<br/>        name         = string<br/>        type         = string<br/>        description  = optional(string)<br/>        display_name = optional(string)<br/>      }))<br/>    })), [])<br/>  }))</pre> | `{}` | no |
| <a name="input_resource_group_id"></a> [resource\_group\_id](#input\_resource\_group\_id) | Resource id of the resource group to create the workspaces in. The name and subscription are parsed from it (pass the rg module's ids output). | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags to apply to the workspaces and solutions. | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_custom_table_ids"></a> [custom\_table\_ids](#output\_custom\_table\_ids) | Map of "<workspace>\|<table>" to the custom log table id. |
| <a name="output_identity_principal_ids"></a> [identity\_principal\_ids](#output\_identity\_principal\_ids) | Map of workspace name to its system-assigned identity principal id (only for workspaces with an identity). |
| <a name="output_primary_shared_keys"></a> [primary\_shared\_keys](#output\_primary\_shared\_keys) | Map of workspace name to its primary shared key. |
| <a name="output_resource_group_name"></a> [resource\_group\_name](#output\_resource\_group\_name) | Resource group name parsed from resource\_group\_id. |
| <a name="output_secondary_shared_keys"></a> [secondary\_shared\_keys](#output\_secondary\_shared\_keys) | Map of workspace name to its secondary shared key. |
| <a name="output_sentinel_onboarding_ids"></a> [sentinel\_onboarding\_ids](#output\_sentinel\_onboarding\_ids) | Map of workspace name to its Sentinel onboarding id (only onboarded workspaces). |
| <a name="output_solution_ids"></a> [solution\_ids](#output\_solution\_ids) | Map of "<workspace>\|<solution>" to the solution id. |
| <a name="output_subscription_id"></a> [subscription\_id](#output\_subscription\_id) | Subscription id parsed from resource\_group\_id. |
| <a name="output_tags"></a> [tags](#output\_tags) | The tags applied to the workspaces. |
| <a name="output_workspace_guids"></a> [workspace\_guids](#output\_workspace\_guids) | Map of workspace name to its workspace (customer) id GUID. |
| <a name="output_workspace_ids"></a> [workspace\_ids](#output\_workspace\_ids) | Map of workspace name to its resource id. |
| <a name="output_workspace_ids_zipmap"></a> [workspace\_ids\_zipmap](#output\_workspace\_ids\_zipmap) | Map of workspace name to a { name, id } object, for passing where both are needed together. |
| <a name="output_workspace_names"></a> [workspace\_names](#output\_workspace\_names) | The workspace names. |
<!-- END_TF_DOCS -->
