# The Auto Scaling Group increases the availability of the bastion by
# replacing an unhealthy EC2 instance or recovering from an
# availability zone failure.
resource "aws_autoscaling_group" "bastion" {
  # The Launch Configuration ID is part of the AUto Scalign Group name,
  # to force the ASG and its EC2 to be recreated.
  name = "asg-${aws_launch_configuration.bastion.id}"

  launch_configuration = aws_launch_configuration.bastion.name
  min_size             = 1
  max_size             = 1
  desired_capacity     = 1
  vpc_zone_identifier  = flatten(var.vpc_subnet_ids)

  tag {
    key                 = "Name"
    value               = var.bastion_name
    propagate_at_launch = true
  }

  # THis needs to match the Launch Configuration.
  lifecycle {
    create_before_destroy = true
  }
}

