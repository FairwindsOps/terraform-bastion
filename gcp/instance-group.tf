resource "google_compute_region_instance_group_manager" "bastion" {
  # The instance template name is part of the instance group name,
  # to force the instance group and compute instance to be recreated.
  name = "igm-${google_compute_instance_template.bastion.name}"

  base_instance_name = var.bastion_name
  version {
    instance_template = google_compute_instance_template.bastion.self_link
  }
  # This is a required parameter and does not use the provider region.
  region                    = var.region
  distribution_policy_zones = var.availability_zones

  target_size = 1

  # This must match the lifecycle from the instance template resource.
  lifecycle {
    create_before_destroy = true
  }
}

