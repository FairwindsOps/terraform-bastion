# The Auto Scaling Group increases the availability of the bastion by
# replacing an unhealthy EC2 instance or recovering from an
# availability zone failure.
resource "aws_autoscaling_group" "bastion" {
  name = "asg-${aws_launch_template.bastion.id}"
  launch_template {
    name = aws_launch_template.bastion.name
    version = aws_launch_template.bastion.latest_version
  }

  min_size            = 1
  max_size            = 1
  desired_capacity    = 1
  vpc_zone_identifier = flatten(var.vpc_subnet_ids)

  tag {
    key                 = "Name"
    value               = var.bastion_name
    propagate_at_launch = true
  }

  dynamic "tag" {
    for_each = var.extra_asg_tags
    content {
      key                 = tag.value["key"]
      value               = tag.value["value"]
      propagate_at_launch = tag.value["propagate_at_launch"]
    }
  }


  # This needs to match the LaunchTemplate.
  lifecycle {
    create_before_destroy = true

    # Allow end user to attach a load balancer with `aws_autoscaling_attachment`.
    ignore_changes = [load_balancers, target_group_arns]
  }
}

