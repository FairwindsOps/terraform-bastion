provider "aws" {
  alias  = "bastion_state"
  region = var.infrastructure_bucket_region
}

locals {
  infrastructure_bucket = data.aws_s3_bucket.infrastructure_bucket
}

data "aws_s3_bucket" "infrastructure_bucket" {
  provider = "aws.bastion_state"
  bucket   = var.infrastructure_bucket
}
