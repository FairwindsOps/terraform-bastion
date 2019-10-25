# The bastion EC2 will write logs to this CloudWatch Log Group.
# Access logs using the AWS CLI or the `awslogs` tool:
#   aws logs get-log-events --log-group-name ${var.bastion_name} --log-stream-name i-05c325b0984289944
# or:
#   awslogs get ${var.bastion_name}
resource "aws_cloudwatch_log_group" "bastion" {
  # THe log group uses a static name to retain all logs across EC2 instances
  # that the Auto Scaling Group recycles.
  name = var.bastion_name

  tags = {
    created_by = "Terraform"
  }

  retention_in_days = var.log_retention
}

