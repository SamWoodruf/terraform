resource "aws_s3_bucket" "root_storage_bucket" {
  bucket = "tf-knoldus-bucket"
  acl    = "private"
  versioning {
    enabled = false
  }
  force_destroy = true
  tags = {
    Name = "${local.prefix}-rootbucket"
  }
}

