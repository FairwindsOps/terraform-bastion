data "aws_region" "current" {}

locals {
  infrastructure_bucket             = data.aws_s3_bucket.infrastructure_bucket
  infrastructure_bucket_region      = data.aws_region.current.name
  infrastructure_bucket_s3_endpoint = format("https://s3.%s.amazonaws.com", data.aws_region.current.name)
}

data "aws_s3_bucket" "infrastructure_bucket" {
  bucket   = var.infrastructure_bucket
}
