
# terraform {
#   required_version = ">= 0.12"
#   required_providers {
#     google   = ">=2.0.0"
#     template = ">=2.1.2"
#   }
# }

terraform {
  version = ">= 0.13"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">=2.0.0"
    }
  }
}
