variable "databricks_host" {
  type 	      = string
  description = "Databricks workspace hostname"
}

variable "databricks_token" {
  type        = string
  description = "Databricks api token"
}

variable "policy_group" {
  description = "Team that performs the work"
}
