
terraform {
  required_version = ">= 0.13"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">=4.27.0"
    }
  }
}

data "google_project" "project" {}
