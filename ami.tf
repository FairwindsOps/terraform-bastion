# This gets the latest AMI for Ubuntu 18.04
data "aws_ami" "ubuntu" {
  most_recent = true

  # THis is Canonical
  owners = ["${var.ami_owner_id}"]

  filter {
    name   = "name"
    values = ["${var.ami_filter_value}"]
  }
}
