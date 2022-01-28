# Terraform module for deploying eks cluster to AWS 
This module provisions a total of 53 resources including:
- Security Groups
- Auto Scaling
- EKS Cluster
- VPC
- Subnets
- Auto Scaling Groups
- EC2 Instances

In order to run this you'll need to have valid AWS credentials on your terminal instance. Run `source ./set_env_vars.sh` to check if your credentials are present. 

Before applying the terraform scripts take a second to add your AWS user arn to the map of allowable users. This will allow you to gain cli access to the cluster via kubectl. To apply the terraform configuration run the deploy script. This may take several minutes to complete. The destroy script will take everything down once it's created successfully.

To see a complete plan for the cluster and cloud setup run the plan script.

To configure kubectl access after cluster creation:
```
aws eks --region $(terraform output -raw region) update-kubeconfig --name $(terraform output -raw cluster_name)
``` 
