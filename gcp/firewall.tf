resource "google_compute_firewall" "bastion_ssh" {
  name        = "bastion-ssh"
  description = "Allow SSH access to the ${var.bastion_name} bastion"
  network     = var.network_name

  source_ranges = var.ssh_cidr_blocks
  target_tags   = ["fw-bastion"]

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }
}

