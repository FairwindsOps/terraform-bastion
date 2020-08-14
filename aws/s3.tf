locals {
  infrastructure_bucket             = data.aws_s3_bucket.infrastructure_bucket
}

data "aws_s3_bucket" "infrastructure_bucket" {
  bucket   = var.infrastructure_bucket
}
