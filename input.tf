variable "create_new_workspace" {
  type        = bool
  description = "Whether or not you wish to create a new workspace, if set to true, a new one will be created, if set to false, a data read will be performed on a data source"
}

variable "daily_quota_gb" {
  type        = string
  description = "The amount of gb set for max daily ingetion"
  default     = ""
}

variable "internet_ingestion_enabled" {
  type        = bool
  description = "Whether internet ingestion is enabled"
  default     = null
}

variable "internet_query_enabled" {
  type        = bool
  description = "Whether or not your workspace can be queried from the internet"
  default     = null
}

variable "law_name" {
  type        = string
  description = "The name of a log analytics workspace"
}

variable "law_sku" {
  type        = string
  description = "The sku of the log analytics workspace"
  default     = ""
}

variable "location" {
  description = "The location for this resource to be put in"
  type        = string
}

variable "reservation_capacity_in_gb_per_day" {
  type        = string
  description = "The reservation capacity gb per day, can only be used with CapacityReservation SKU"
  default     = ""
}

variable "retention_in_days" {
  type        = string
  description = "The number of days for retention, between 7 and 730"
  default     = ""
}

variable "rg_name" {
  description = "The name of the resource group, this module does not create a resource group, it is expecting the value of a resource group already exists"
  type        = string
  validation {
    condition     = length(var.rg_name) > 1 && length(var.rg_name) <= 24
    error_message = "Resource group name is not valid."
  }
}

variable "tags" {
  type        = map(string)
  description = "A map of the tags to use on the resources that are deployed with this module."

  default = {
    source = "terraform"
  }
}
