```hcl
module "law" {
  source = "registry.terraform.io/libre-devops/log-analytics-workspace/azurerm"

  rg_name  = module.rg.rg_name
  location = module.rg.rg_location
  tags     = module.rg.rg_tags

  create_new_workspace       = true
  law_name                   = "law-${var.short}-${var.loc}-${terraform.workspace}-01"
  law_sku                    = "PerNode"
  retention_in_days          = "30"
  daily_quota_gb             = "0.5"
  internet_ingestion_enabled = false
  internet_query_enabled     = false
}
```

## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [azurerm_log_analytics_workspace.law](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/log_analytics_workspace) | resource |
| [azurerm_log_analytics_workspace.read_created_law](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/log_analytics_workspace) | data source |
| [azurerm_log_analytics_workspace.read_law](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/log_analytics_workspace) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_create_new_workspace"></a> [create\_new\_workspace](#input\_create\_new\_workspace) | Whether or not you wish to create a new workspace, if set to true, a new one will be created, if set to false, a data read will be performed on a data source | `bool` | n/a | yes |
| <a name="input_daily_quota_gb"></a> [daily\_quota\_gb](#input\_daily\_quota\_gb) | The amount of gb set for max daily ingetion | `string` | `""` | no |
| <a name="input_internet_ingestion_enabled"></a> [internet\_ingestion\_enabled](#input\_internet\_ingestion\_enabled) | Whether internet ingestion is enabled | `bool` | `null` | no |
| <a name="input_internet_query_enabled"></a> [internet\_query\_enabled](#input\_internet\_query\_enabled) | Whether or not your workspace can be queried from the internet | `bool` | `null` | no |
| <a name="input_law_name"></a> [law\_name](#input\_law\_name) | The name of a log analytics workspace | `string` | n/a | yes |
| <a name="input_law_sku"></a> [law\_sku](#input\_law\_sku) | The sku of the log analytics workspace | `string` | `""` | no |
| <a name="input_location"></a> [location](#input\_location) | The location for this resource to be put in | `string` | n/a | yes |
| <a name="input_reservation_capacity_in_gb_per_day"></a> [reservation\_capacity\_in\_gb\_per\_day](#input\_reservation\_capacity\_in\_gb\_per\_day) | The reservation capacity gb per day, can only be used with CapacityReservation SKU | `string` | `""` | no |
| <a name="input_retention_in_days"></a> [retention\_in\_days](#input\_retention\_in\_days) | The number of days for retention, between 7 and 730 | `string` | `""` | no |
| <a name="input_rg_name"></a> [rg\_name](#input\_rg\_name) | The name of the resource group, this module does not create a resource group, it is expecting the value of a resource group already exists | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | A map of the tags to use on the resources that are deployed with this module. | `map(string)` | <pre>{<br>  "source": "terraform"<br>}</pre> | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_law_id"></a> [law\_id](#output\_law\_id) | The  id of the log analytics workspace. If a new log analytic workspace is created, fetch its data id, if one is created, fetch the remote one instead |
| <a name="output_law_name"></a> [law\_name](#output\_law\_name) | The name of the log analytics workspace |
| <a name="output_law_primary_key"></a> [law\_primary\_key](#output\_law\_primary\_key) | The primary key of the log analytics workspace. If a new log analytic workspace is created, fetch its data id, if one is created, fetch the remote one instead |
| <a name="output_law_secondary_key"></a> [law\_secondary\_key](#output\_law\_secondary\_key) | The primary key of the log analytics workspace. If a new log analytic workspace is created, fetch its data id, if one is created, fetch the remote one instead |
| <a name="output_law_workspace_id"></a> [law\_workspace\_id](#output\_law\_workspace\_id) | The workspace id of the log analytics workspace. If a new log analytic workspace is created, fetch its data id, if one is created, fetch the remote one instead |
