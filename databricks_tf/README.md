# Terraform Script to Provision Databricks Workspace on AWS

Requires valid aws cli credentials and premium or enterprise databricks account. Enter your databricks credentials in the deploy and destroy scripts.
Run the `set_env_var.sh` script to set the aws region to use and view the active aws account on your terminal: `source set_env_vars.sh`.

Use the `deploy` script to run the terraform configuration. `destroy` will remove everything once it's been created. 

This will provision 29 resources including:
- Cross Account Role
- VPC
- Root Bucket(For DBFS)
- VPC Endpoint
- Subnets
- NAT Gateway
- Databricks Workspace
- Databricks Cluster

For a complete list of resources run the `plan` script.
