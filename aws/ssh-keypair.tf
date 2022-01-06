resource "aws_key_pair" "bastion" {
  count = var.ssh_public_key_file == "" ? 0 : 1

  key_name_prefix = "${var.bastion_name}-"
  public_key      = var.ssh_public_key_file
}

