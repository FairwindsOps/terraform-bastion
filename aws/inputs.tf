variable "bastion_name" {
  description = "The name of the bastion EC2 instance, DNS hostname, CloudWatch Log Group, and the name prefix for other related resources."
  default     = "ro-bastion"
}

variable "infrastructure_bucket" {
  description = "An S3 bucket to store data that should persist on the bastion when it is recycled by the Auto Scaling Group, such as SSH host keys. This can be set in the environment via `TF_VAR_infrastructure_bucket`"
}

variable "infrastructure_bucket_bastion_key" {
  description = "The key; sub-directory in $infrastructure_bucket where the bastion will be allowed to read and write. Do not specify a trailing slash. This allows sharing an S3 bucket among multiple invocations of this module."
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

variable "additional_user_data" {
  description = "Content to be appended to UserData, which is run the first time the bastion EC2 boots."
  default     = ""
}

variable "instance_type" {
  description = "The EC2 instance type of the bastion."
  default     = "t3.micro"
}

variable "route53_zone_id" {
  # This zone ID is turned into a zone name by the `register-dns` script,
  # which is created by user-data.
  description = "ID of the ROute53 zone for the bastion to add its host record."
}

variable "log_retention" {
  description = "The number of days to retain logs in the CloudWatch Log Group."
  default     = "60"
}

variable "vpc_id" {
  description = "The VPC ID where the bastion and its security group will be created. This must match subnet IDs specified in the `vpc_subnet_ids` input."
}

variable "vpc_subnet_ids" {
  type        = list
  description = "A list of subnet IDs where the Auto Scaling Group can place the bastion."
}

variable "ssh_public_key_file" {
  description = "The content of an existing SSH public key file, that will be used to create an AWS SSH Key Pair. Yes, this input has an unfortunate name."
  default     = ""
}

variable "ssh_cidr_blocks" {
  type        = list(string)
  description = "A list of CIDRs allowed to SSH to the bastion. Override the module default by specifying an empty list, []"
  default     = ["0.0.0.0/0"]
}

variable "ami_owner_id" {
  description = "The ID of the AMI's owner in AWS. The default is Canonical."
  default     = "099720109477"
}

variable "ami_owner_id_govcloud" {
  description = "The ID of the AMI's owner in AWS GovCloud. This value is used automatically if the module's `arn_prefix` input variable is anything other than `arn:aws`. The default is Canonical."
  default     = "513442679011"
}

variable "ami_filter_value" {
  description = "The filter path for the AMI."
  default     = "ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"
}

variable "arn_prefix" {
  description = "The prefix to use for AWS ARNs."
  default     = "arn:aws"
}

variable "encrypt_root_volume" {
  description = "If true, encrypt the root ebs volume of the bastion"
  default     = true
}

variable "extra_asg_tags" {
  type        = list
  description = "Extra tags for the bastion autoscaling group"
  default     = []
}

variable "root_volume_type" {
  type        = string
  description = "The root volume type for the bastion instance"
  default     = "gp3"
}