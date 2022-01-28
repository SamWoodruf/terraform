resource "random_string" "naming" {
  special = false
  upper   = false
  length  = 6
}

locals {
  prefix = "demo${random_string.naming.result}"
}

variable "region" {
  type        = string
  description = "AWS Region where resources should be created"
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

