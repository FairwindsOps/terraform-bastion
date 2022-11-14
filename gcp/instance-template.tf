data "template_file" "bastion_setup_script" {
  template = file("${path.module}/bastion-startup-script.tmpl")

  vars = {
    bastion_name                      = var.bastion_name
    infrastructure_bucket             = var.infrastructure_bucket
    infrastructure_bucket_bastion_key = var.infrastructure_bucket_bastion_key
    # THe Google DNS zone to add a `bastion` A record.
    zone_name = var.dns_zone_name
    # Configuration options for unattended upgrades, added to /etc/apt/apt.conf.d/50unattended-upgrades
    unattended_upgrade_reboot_time        = var.unattended_upgrade_reboot_time
    unattended_upgrade_email_recipient    = var.unattended_upgrade_email_recipient
    unattended_upgrade_additional_configs = var.unattended_upgrade_additional_configs
    remove_root_access                    = var.remove_root_access
    additional_setup_script               = var.additional_setup_script
    # Join the rendered templates per additional user into a single string variable.

    additional_user_templates            = join("\n", data.template_file.additional_user.*.rendered)
    additional-external-users-script-md5 = local.additional-external-users-script-md5
  }
}

resource "google_compute_instance_template" "bastion" {
  name_prefix = var.bastion_name
  description = "${var.bastion_name} bastion"

  # The tag named after the bastion, is required for the SSH firewall rule.
  tags = [var.bastion_name, "terraform-managed"]

  instance_description = "${var.bastion_name} bastion"
  machine_type         = var.machine_type
  can_ip_forward       = false

  scheduling {
    automatic_restart   = true
    on_host_maintenance = "MIGRATE"
  }

  disk {
    source_image = data.google_compute_image.ubuntu.self_link
    auto_delete  = true
    boot         = true
  }

  network_interface {
    subnetwork = var.subnetwork_name
    # This is required to configure a public IP address.
    access_config {}
  }

  shielded_instance_config {
    enable_secure_boot = var.enable_secure_boot
  }

  confidential_instance_config {
    enable_confidential_compute = var.enable_confidential_nodes
  }

  service_account {
    email = google_service_account.bastion.email

    # Best practice is to use IA M roles to narrow permissions granted by scopes.
    scopes = ["compute-ro", "storage-rw", "https://www.googleapis.com/auth/ndev.clouddns.readwrite"]
  }

  # Ref for GCE SSH key management: https://cloud.google.com/compute/docs/instances/adding-removing-ssh-keys
  metadata = {
    block-project-ssh-keys = "TRUE"
    ssh-keys               = "ubuntu:${var.ssh_public_key_file}"
  }
  metadata_startup_script = data.template_file.bastion_setup_script.rendered

  # THis must match the lifecycle for the instance group resource.
  lifecycle {
    create_before_destroy = true
  }
}

