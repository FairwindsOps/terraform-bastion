# This gets the latest AMI for Ubuntu 18.04
data "aws_ami" "ubuntu" {
  most_recent = true

  # THis is Canonical
  owners = ["099720109477"]

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-bionic-18.04-amd64-server-*"]
  }
}
