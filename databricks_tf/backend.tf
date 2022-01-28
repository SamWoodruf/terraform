terraform {
  backend "s3" {
    bucket = "tf-knoldus-bucket"
    key    = "databricks_tf"
    region = "us-east-2"
  }
}
