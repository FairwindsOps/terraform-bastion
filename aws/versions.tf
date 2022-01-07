
# terraform {
#   required_version = ">= 0.12"
#   required_providers {
#     aws = ">=2.30.0"
#   }
# }

terraform {
  required_version = ">= 0.13"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">=2.30.0"
    }
  }
}
