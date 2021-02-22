variable "bastion_name" {
  description = "The name of the bastion compute instance, DNS hostname, IAM service account, and the prefix for resources such as the firewall rule, instance template, and instance group."
  default     = "ro-bastion"
}

variable "region" {
  description = "The region where the bastion should be provisioned. This is a required input for the google_compute_region_instance_group_manager Terraform resource, and is not inherited from the provider."
}

variable "availability_zones" {
  description = "The availability zones within $region where the Auto Scaling Group can place the bastion."
  type        = list
}

variable "infrastructure_bucket" {
  description = "An GCS bucket to store data that should persist on the bastion when it is recycled by the Auto Scaling Group, such as SSH host keys. This can be set in the environment via `TF_VAR_infrastructure_bucket`"
}

variable "infrastructure_bucket_bastion_key" {
  description = "The key; sub-directory in $infrastructure_bucket where the bastion will be allowed to read and write. Do not specify a trailing slash. This allows sharing a GCS bucket among multiple invocations of this module."
  default     = "bastion"
}

variable "unattended_upgrade_reboot_time" {
  description = "The time that the bastion should reboot, when necessary, after an an unattended upgrade. This sets the option in /etc/apt/apt.conf.d/50unattended-upgrades"

  # By default the time zone is UTC.
  default = "21:30"
}

variable "unattended_upgrade_email_recipient" {
  description = "An email address where unattended upgrade errors should be emailed. THis sets the option in /etc/apt/apt.conf.d/50unattended-upgrades"
}

variable "unattended_upgrade_additional_configs" {
  description = "Additional configuration lines to add to /etc/apt/apt.conf.d/50unattended-upgrades"
  default     = ""
}

variable "remove_root_access" {
  description = "Whether to remove root access from the ubuntu user. Set this to yes|true|1 to remove root access, or anything else to retain it."

  default = "true"
}

variable "additional_users" {
  type        = list
  description = "Additional users to be created on the bastion. Specify users as a list of maps. See an example in the `example-usage` file. Required map keys are `login` (user name) and `authorized_keys`. Optional map keys are `gecos` (full name), `supplemental_groups` (comma-separated), and `shell`. The authorized_keys will be output to ~/.ssh/authorized_keys using printf - multiple keys can be specified by including \\n in the string."
  default     = []
}

variable "additional_external_users" {
  type        = list
  description = "Additional users to be created on the bastion. Works the same as additional_users, but adds users via a separate systemd unit file. Specify users as a list of maps. See an example in the `example-usage` file. Required map keys are `login` (user name) and `authorized_keys`. Optional map keys are `gecos` (full name), `supplemental_groups` (comma-separated), and `shell`. The authorized_keys will be output to ~/.ssh/authorized_keys using printf - multiple keys can be specified by including \\n in the string."
  default     = []
}

variable "additional_setup_script" {
  description = "Content to be appended to the setup script, which is run the first time the bastion compute instance boots."
  default     = ""
}

variable "machine_type" {
  description = "The GCE machine type of the bastion."
  default     = "n1-standard-1"
}

variable "dns_zone_name" {
  description = "The name of the Google DNS zone for the bastion to add its host record. Specify the name of the managed zone, not the domain name."
}

variable "subnetwork_name" {
  description = "The name of the existing subnetwork where the bastion will be created."
}

variable "network_name" {
  description = "The name of the network where the bastion SSH firewall rule will be created. This network is the parent of $subnetwork"
}

variable "ssh_public_key_file" {
  description = "The content of an existing SSH public key file, that will be used with the `ssh-keys` GCP metadata to allow SSH access. Yes, this input has an unfortunate name."
}

variable "ssh_cidr_blocks" {
  type        = list(string)
  description = "A list of CIDRs allowed to SSH to the bastion. Override the module default by specifying an empty list, []"
  default     = ["0.0.0.0/0"]
}

variable "image_family" {
  description = "The family for the compute image. This module has assumptions about the OS being Ubuntu."
  default     = "ubuntu-1804-lts"
}

variable "image_project" {
  description = "The project of the compute image owner."
  default     = "ubuntu-os-cloud"
}

