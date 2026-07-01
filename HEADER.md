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
