output "security_group_id" {
  value        = aws_security_group.bastion_ssh.id
  descriptipon = "The ID of the bastion security group"
}
