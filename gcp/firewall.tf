resource "google_compute_firewall" "bastion_ssh" {
  # Only add this rule if the list of ssh_cidr_blocks is set.
  count             = length(var.ssh_cidr_blocks) > 0 ? 1 : 0
  name        = "${var.bastion_name}-ssh"
  description = "Allow SSH access to the ${var.bastion_name} bastion"
  network     = var.network_name

  source_ranges = var.ssh_cidr_blocks
  target_tags   = [var.bastion_name]

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }
}

