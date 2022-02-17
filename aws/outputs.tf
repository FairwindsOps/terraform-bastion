output "security_group_id" {
  value       = aws_security_group.bastion_ssh.id
  description = "The ID of the bastion security group"
}

output "autoscaling_group_id" {
  value       = aws_autoscaling_group.bastion.id
  description = "The ID of the autoscaling group"
}

output "autoscaling_group_arn" {
  value       = aws_autoscaling_group.bastion.arn
  description = "The ARN of the autoscaling group"
}