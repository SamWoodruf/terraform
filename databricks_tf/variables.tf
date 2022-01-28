variable "databricks_account_username" {
  type 	      = string
  description = "Databricks username"
}

variable "databricks_account_password" {
  type        = string
  description = "Databricks password"
}

variable "databricks_account_id" {
  type        = string
  description = "Databricks account id"
}

variable "tags" {
  default = {}
}

variable "cidr_block" {
  default = "10.4.0.0/16"
}

variable "region" {
  default = "eu-west-1"
}

variable "aws_access_key" {
  type        = string
  description = "AWS Access Key"
}


variable "aws_secret_key" {
  type        = string
  description = "AWS Secret Key"
}

variable "aws_token" {
  type        = string
  description = "AWS token from mfa"
}

variable "kubeconfig" {
  type        = string
  description = "Config for kuberetes context"
}

variable "kubecontext" {
  type        = string
  description = "Current kubernetes context"
}

