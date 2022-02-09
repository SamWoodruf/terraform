terraform {
    required_providers {
    databricks = {
      source  = "databrickslabs/databricks"
      version = "0.4.5"
    }
    aws = {
      source  = "hashicorp/aws"
      version = "3.49.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "2.7.1"
    }
  }
}

# provider "kubernetes" {
#  config_path    = var.kubeconfig
#  config_context = var.kubecontext
# }

provider "aws" {
  region = var.region
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
  token = var.aws_token
}
