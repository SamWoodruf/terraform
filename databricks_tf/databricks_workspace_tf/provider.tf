provider "databricks" {
  alias    = "mws"
  host     = "https://accounts.cloud.databricks.com/"
  username = var.databricks_account_username
  password = var.databricks_account_password
}
