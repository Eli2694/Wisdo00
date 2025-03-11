resource "aws_alb" "application_load_balancer" {
  for_each = var.alb

  name               = each.key
  load_balancer_type = each.value.load_balancer_type
  enable_http2       = each.value.enable_http2
  internal           = each.value.internal

  security_groups = [
    for security_group_name in  each.value.security_group_name : aws_security_group.sg[security_group_name].id
  ]

  subnets = [
    for subnet_name in each.value.subnet_name : aws_subnet.private_subnets[subnet_name].id
  ]
  
}

resource "aws_lb_target_group" "http" {
  for_each = var.alb-target-groups-http
  name             = each.key
  port             = each.value.port
  protocol         = each.value.protocol
  protocol_version = each.value.protocol_version
  target_type      = each.value.target_type
  vpc_id           = aws_vpc.main[each.value.vpc_name].id
  health_check {
    protocol            = each.value.health_check.port
    path                = each.value.health_check.path
    matcher             = each.value.health_check.matcher
    interval            = each.value.health_check.interval
    timeout             = each.value.health_check.timeout
    healthy_threshold   = each.value.health_check.healthy_threshold
    unhealthy_threshold = each.value.health_check.unhealthy_threshold
  }
}

resource "aws_lb_listener" "alb_https" {
  for_each = var.alb-listeners

      
  load_balancer_arn = aws_lb.application_load_balancer[each.value.load_balancer_name].arn
  port              = each.value.port
  protocol          = each.value.protocol
  ssl_policy        = each.value.ssl_policy
  certificate_arn   = "" # SSL cert from AWS ACM

  default_action {
    type             = each.value.type
    target_group_arn = aws_lb_target_group.http[each.value.target_group_name].arn
  }
}

