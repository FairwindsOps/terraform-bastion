resource "aws_security_group" "bastion_ssh" {
  name_prefix = "${var.bastion_name}-"
  description = "Allow inbound Bastion SSH and all outbound traffic"

  vpc_id = var.vpc_id
  # Destroy other non-Terraform-managed rules, if the security group needs to be destroyed.
  revoke_rules_on_delete = true

  lifecycle {
    ignore_changes = [tags]
  }
}

resource "aws_security_group_rule" "bastion_ssh" {
  # Only add this rule if the list of ssh_cidr_blocks is set.
  count             = length(var.ssh_cidr_blocks) > 0 ? 1 : 0
  type              = "ingress"
  description       = "Terraform-managed SSH access"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = var.ssh_cidr_blocks
  security_group_id = aws_security_group.bastion_ssh.id
}

resource "aws_security_group_rule" "bastion_ssh_ipv6" {
  # Only add this rule if the list of ssh_cidr_blocks is set.
  count             = length(var.ssh_ipv6_cidr_blocks) > 0 ? 1 : 0
  type              = "ingress"
  description       = "Terraform-managed SSH access"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  ipv6_cidr_blocks  = var.ssh_ipv6_cidr_blocks
  security_group_id = aws_security_group.bastion_ssh.id
}

resource "aws_security_group_rule" "bastion_egress" {
  type              = "egress"
  description       = "Terraform-managed bastion egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  ipv6_cidr_blocks  = ["::/0"]
  security_group_id = aws_security_group.bastion_ssh.id
}
