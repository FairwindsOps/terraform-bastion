
terraform {
  required_version = ">= 0.13"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">=2.0.0"
    }
  }
}

data "google_project" "project" {}