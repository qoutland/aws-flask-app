resource "aws_ecs_cluster" "cluster" {
  name = "${var.name}-cluster"
}

# Task Def
resource "aws_ecs_task_definition" "task" {
  family                   = "${var.name}-task"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = var.task_cpu
  memory                   = var.task_mem
  container_definitions = jsonencode([
    {
      name      = "app"
      image     = "${var.docker_image}:${var.docker_tag}"
      cpu       = var.task_cpu
      memory    = var.task_mem
      essential = true
      portMappings = [
        {
          containerPort = 80
          hostPort      = 80
        }
      ]
    }
  ])
}

# Service
resource "aws_ecs_service" "app" {
  name                               = "${var.name}-service"
  cluster                            = aws_ecs_cluster.cluster.id
  task_definition                    = aws_ecs_task_definition.task.arn
  launch_type                        = "FARGATE"
  desired_count                      = var.task_min_num
  deployment_maximum_percent         = 200
  deployment_minimum_healthy_percent = 100
  health_check_grace_period_seconds  = 10
  network_configuration {
    subnets         = aws_subnet.private_subnet[*].id
    security_groups = [aws_security_group.ecs_sg.id]
  }
  load_balancer {
    target_group_arn = aws_lb_target_group.tg.arn
    container_name   = "app"
    container_port   = 80
  }
  lifecycle {
    ignore_changes = [desired_count]
  }
}

# Auto scaling policy
resource "aws_appautoscaling_target" "ecs_target" {
  max_capacity       = var.task_max_num
  min_capacity       = var.task_min_num
  resource_id        = "service/${aws_ecs_cluster.cluster.name}/${aws_ecs_service.app.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
}

resource "aws_appautoscaling_policy" "cpu" {
  name               = "${var.name}-scaling-polcy"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.ecs_target.resource_id
  scalable_dimension = aws_appautoscaling_target.ecs_target.scalable_dimension
  service_namespace  = aws_appautoscaling_target.ecs_target.service_namespace
  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }
    # Scale up when cpu hits 70%
    target_value       = 70
    scale_out_cooldown = 60
    scale_in_cooldown  = 90
  }

}