# This gets the latest AMI for Ubuntu 18.04
data "google_compute_image" "ubuntu" {
  # Ref: https://cloud.google.com/compute/docs/images
  family  = var.image_family
  project = var.image_project
}

