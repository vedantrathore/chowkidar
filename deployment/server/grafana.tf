#####################################
# ECS service for Grafana
#####################################
module "container_definition_chowkidar_grafana" {
  source  = "cloudposse/ecs-container-definition/aws"
  version = "v0.23.0"

  container_name  = "chowkidar-grafana"
  container_image = var.grafana_image

  container_cpu                = 256
  container_memory             = 512
  container_memory_reservation = 128

  port_mappings = [
    {
      containerPort = 3000
      hostPort      = 3000
      protocol      = "tcp"
    },
  ]

  log_configuration = {
    logDriver = "awslogs"
    options = {
      awslogs-region        = data.aws_region.current.name
      awslogs-group         = aws_cloudwatch_log_group.chowkidar_grafana.name
      awslogs-stream-prefix = "ecs"
    }
    secretOptions = []
  }

  environment = concat(
    local.grafana_container_definition_environment
  )

  secrets = concat(
    local.grafana_container_definition_secrets,
    var.custom_environment_secrets,
  )
}

resource "aws_ecs_task_definition" "chowkidar_grafana" {
  family                   = "chowkidar-server"
  execution_role_arn       = aws_iam_role.ecs_task_execution.arn
  task_role_arn            = aws_iam_role.ecs_task_execution.arn
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = 256
  memory                   = 512

  container_definitions = module.container_definition_chowkidar_server.json

  tags = local.tags
}

data "aws_ecs_task_definition" "chowkidar_grafana" {
  task_definition = "chowkidar-grafana"

  depends_on = [aws_ecs_task_definition.chowkidar_grafana]
}

resource "aws_ecs_service" "chowkidar_grafana" {
  name    = "chowkidar-grafana"
  cluster = module.ecs.this_ecs_cluster_id
  task_definition = "${data.aws_ecs_task_definition.chowkidar_grafana.family}:${max(
    aws_ecs_task_definition.chowkidar_grafana.revision,
    data.aws_ecs_task_definition.chowkidar_grafana.revision,
  )}"
  desired_count                      = 1
  deployment_minimum_healthy_percent = 50
  launch_type                        = "FARGATE"
  deployment_maximum_percent         = 200

  network_configuration {
    subnets          = var.private_subnet_ids
    security_groups  = [module.chowkidar_sg.this_security_group_id]
    assign_public_ip = false
  }

  load_balancer {
    container_name   = "chowkidar-grafana"
    container_port   = 3000
    target_group_arn = element(module.alb.target_group_arns, 1)
  }

  tags = local.tags
}
