variable "bastion_name" {
  description = "The name of the bastion EC2 instance, DNS hostname, CloudWatch Log Group, and the name prefix for other related resources."
  default     = "ro-bastion"
}

variable "infrastructure_bucket" {
  description = "THe S3 bucket used for infrastructure, the INFRASTRUCTURE_BUCKET Pentagon environment variable. This is intended to be set in the environment via `TF_VAR_infrastructure_bucket`"
}

variable "infrastructure_bucket_bastion_key" {
  description = "The key; sub-directory in $infrastructure_bucket where the bastion will be allowed to read and write. Do not specify a trailing slash. This location is used to store data that should persist on the bastion when it is recycled by the Auto Scaling Group."
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

variable "instance_type" {
  description = "The EC2 instance type of the bastion."
  default     = "t2.micro"
}

variable "route53_zone_id" {
  # This zone ID is turned into a zone name by the `register-dns` script,
  # which is created by user-data.
  description = "ID of the ROute53 zone for the bastion to add its `bastion` record."
}

variable "log_retention" {
  description = "The number of days to retain logs in the CloudWatch Log Group."
  default     = "60"
}

variable "vpc_id" {
  description = "The VPC ID where the bastion and its security group will be created. This must match subnet IDs specified in the `vpc_subnet_ids` variable"
}

variable "vpc_subnet_ids" {
  type        = "list"
  description = "A list of subnet IDs where the Auto Scaling Group can place the bastion."
}

variable "ssh_public_key_file" {
  description = "The path to an existing SSH public key file, that will be used to create an AWS SSH Key Pair."
}

variable "ssh_cidr_blocks" {
  type        = "list"
  description = "A list of CIDRs allowed to SSH to the bastion."
  default     = ["0.0.0.0/0"]
}
