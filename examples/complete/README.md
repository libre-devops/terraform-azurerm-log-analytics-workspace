<!--
  Header for the complete example README. Edit this file, then run `just docs`
  (or ./Sort-LdoTerraform.ps1 -IncludeExamples) to regenerate the section between the markers.
  The example's main.tf is embedded into the README automatically (see .terraform-docs.yml).
-->
<div align="center">
  <a href="https://libredevops.org">
    <picture>
      <source media="(prefers-color-scheme: dark)" srcset="https://libredevops.org/assets/libre-devops-white.png">
      <img alt="Libre DevOps" src="https://libredevops.org/assets/libre-devops-black.png" width="200">
    </picture>
  </a>
</div>

# Complete example

Exercises the fuller surface of this module. The environment comes from the Terraform workspace
(`terraform.workspace`), not a variable. Run it with `just e2e complete`, which applies the stack
then always destroys it.

[![Terraform Registry](https://img.shields.io/badge/registry-libre--devops-7B42BC?logo=terraform&logoColor=white)](https://registry.terraform.io/namespaces/libre-devops)

<!-- BEGIN_TF_DOCS -->
## Example configuration

```hcl
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
```

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.9.0, < 2.0.0 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | >= 4.0.0, < 5.0.0 |

## Providers

No providers.

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_log_analytics"></a> [log\_analytics](#module\_log\_analytics) | ../../ | n/a |
| <a name="module_rg"></a> [rg](#module\_rg) | libre-devops/rg/azurerm | ~> 4.0 |
| <a name="module_tags"></a> [tags](#module\_tags) | libre-devops/tags/azurerm | ~> 4.0 |

## Resources

No resources.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_deployed_branch"></a> [deployed\_branch](#input\_deployed\_branch) | Git branch the deployment came from. Auto-filled in CI from TF\_VAR\_deployed\_branch. | `string` | `""` | no |
| <a name="input_deployed_repo"></a> [deployed\_repo](#input\_deployed\_repo) | Repository URL the deployment came from. Auto-filled in CI from TF\_VAR\_deployed\_repo. | `string` | `""` | no |
| <a name="input_loc"></a> [loc](#input\_loc) | Outfix: short Azure region code used in resource names (for example uks). | `string` | `"uks"` | no |
| <a name="input_regions"></a> [regions](#input\_regions) | Map of short region codes to Azure region slugs. | `map(string)` | <pre>{<br/>  "eus": "eastus",<br/>  "euw": "westeurope",<br/>  "uks": "uksouth",<br/>  "ukw": "ukwest"<br/>}</pre> | no |
| <a name="input_short"></a> [short](#input\_short) | Infix: short product code used in resource names. | `string` | `"ldo"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_custom_table_ids"></a> [custom\_table\_ids](#output\_custom\_table\_ids) | The custom log table ids. |
| <a name="output_sentinel_onboarding_ids"></a> [sentinel\_onboarding\_ids](#output\_sentinel\_onboarding\_ids) | The Sentinel onboarding ids. |
| <a name="output_solution_ids"></a> [solution\_ids](#output\_solution\_ids) | The solution ids. |
| <a name="output_tags"></a> [tags](#output\_tags) | The tags applied to the resources. |
| <a name="output_workspace_ids"></a> [workspace\_ids](#output\_workspace\_ids) | Map of workspace name to resource id. |
<!-- END_TF_DOCS -->
