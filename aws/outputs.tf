output "security_group_id" {
  value       = aws_security_group.bastion_ssh.id
  description = "The ID of the bastion security group"
}

output "alb_dns_name" {
  value       = aws_alb.bastion_alb[0].dns_name
  description = "The DNS name of the bastion load balancer"
}

output "alb_arn" {
  value       = aws_alb.bastion_alb[0].arn
  description = "The ARN of the bastion load balancer"
}

output "alb_id" {
  value       = aws_alb.bastion_alb[0].id
  description = "The ID of the bastion load balancer"
}
