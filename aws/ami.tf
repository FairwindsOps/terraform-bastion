# This gets the latest AMI for Ubuntu 18.04
data "aws_ami" "ubuntu" {
  most_recent = true

  # This is Canonical
  owners = [var.arn_prefix == "arn:aws" ? var.ami_owner_id : var.ami_owner_id_govcloud]

  filter {
    name   = "name"
    values = [var.ami_filter_value]
  }
}

