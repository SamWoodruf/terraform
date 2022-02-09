
module "databricks_workspace" {
  source                              = "./databricks_workspace_tf"
  databricks_account_username         = var.databricks_account_username
  databricks_account_password         = var.databricks_account_password
  databricks_account_id               = var.databricks_account_id
  region                              = var.region
  aws_access_key                      = var.aws_access_key
  aws_secret_key                      = var.aws_secret_key
  aws_token                           = var.aws_token
  kubeconfig                          = var.kubeconfig
  kubecontext                         = var.kubecontext
}

module "databricks_cluster" {
  source                              = "./databricks_cluster_tf"
  databricks_host		      = module.databricks_workspace.databricks_host
  databricks_token                    = module.databricks_workspace.databricks_token 
  policy_group                        = var.databricks_cluster_policy_group
}

output "databricks_host" {
  value = module.databricks_workspace.databricks_host
}

output "databricks_token" {
  value     = module.databricks_workspace.databricks_host
  sensitive = true
}
