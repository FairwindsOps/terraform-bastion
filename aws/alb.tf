resource "aws_alb" "bastion_alb" {
  count = var.alb_name == "" ? 0 : 1

  name                             = var.alb_name
  internal                         = false
  load_balancer_type               = "network"
  subnets                          = flatten(var.vpc_subnet_ids)
  enable_cross_zone_load_balancing = true
}

resource "aws_alb_listener" "bastion_alb" {
  count = var.alb_name == "" ? 0 : 1

  load_balancer_arn = aws_alb.bastion_alb[0].arn
  port              = 22
  protocol          = "TCP"

  default_action {
    target_group_arn = aws_alb_target_group.bastion_alb[0].arn
    type             = "forward"
  }

  depends_on = [aws_alb_target_group.bastion_alb[0]]
}

resource "aws_alb_target_group" "bastion_alb" {
  count = var.alb_name == "" ? 0 : 1

  name     = var.alb_name
  port     = 22
  protocol = "TCP"
  vpc_id   = var.vpc_id

  health_check {
    enabled             = true
    port                = 22
    protocol            = "TCP"
    healthy_threshold   = 2
    unhealthy_threshold = 2
    interval            = 30
  }
}

resource "aws_autoscaling_attachment" "bastion" {
  count = var.alb_name == "" ? 0 : 1

  autoscaling_group_name = aws_autoscaling_group.bastion.id
  elb                    = aws_alb.bastion_alb.id
}
