resource "aws_lb" "alb" {
  name               = "${var.name}-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]
  subnets            = aws_subnet.public_subnet[*].id
  tags               = local.tags
}

resource "aws_lb_target_group" "tg" {
  name                 = "${var.name}-tg"
  port                 = 80
  protocol             = "HTTP"
  target_type          = "ip"
  vpc_id               = aws_vpc.vpc.id
  deregistration_delay = 15
}

resource "aws_lb_listener" "listener" {
  load_balancer_arn = aws_lb.alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tg.arn
  }
}