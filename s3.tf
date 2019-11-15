data "aws_region" "current" {}

provider "aws" {
  alias  = "bastion_state"
  region = local.infrastructure_bucket_region
  endpoints {
    s3 = local.infrastructure_bucket_s3_endpoint
  }
}

locals {
  infrastructure_bucket             = data.aws_s3_bucket.infrastructure_bucket
  infrastructure_bucket_region      = var.infrastructure_bucket_region == null ? data.aws_region.current.name : var.infrastructure_bucket_region
  infrastructure_bucket_s3_endpoint = var.infrastructure_bucket_region == data.aws_region.current.name ? format("https://s3.%s.amazonaws.com", data.aws_region.current.name) : format("https://s3.%s.amazonaws.com", local.infrastructure_bucket_region)
}

data "aws_s3_bucket" "infrastructure_bucket" {
  provider = aws.bastion_state
  bucket   = var.infrastructure_bucket
}
