#####################################
# ECS service for InfluxDB
#####################################
module "container_definition_chowkidar_influxdb" {
  source  = "cloudposse/ecs-container-definition/aws"
  version = "v0.23.0"

  container_name  = "chowkidar-influxdb"
  container_image = var.influxdb_image

  container_cpu                = 256
  container_memory             = 512
  container_memory_reservation = 128

  port_mappings = [
    {
      containerPort = 8086
      hostPort      = 8086
      protocol      = "tcp"
    },
  ]

  log_configuration = {
    logDriver = "awslogs"
    options = {
      awslogs-region        = data.aws_region.current.name
      awslogs-group         = aws_cloudwatch_log_group.chowkidar_influxdb.name
      awslogs-stream-prefix = "ecs"
    }
    secretOptions = []
  }

  environment = concat(
    local.influxdb_container_definition_environment
  )

  secrets = concat(
    local.influxdb_container_definition_secrets,
    var.custom_environment_secrets,
  )
}

resource "aws_ecs_task_definition" "chowkidar_influxdb" {
  family                   = "chowkidar-influxdb"
  execution_role_arn       = aws_iam_role.ecs_task_execution.arn
  task_role_arn            = aws_iam_role.ecs_task_execution.arn
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = 256
  memory                   = 512

  container_definitions = module.container_definition_chowkidar_influxdb.json

  volume {
    name = "influx-db"

    efs_volume_configuration {
      file_system_id = aws_efs_file_system.ecs_service_storage.id
      root_directory = "/influxdb"
    }
  }

  tags = local.tags
}

data "aws_ecs_task_definition" "chowkidar_influxdb" {
  task_definition = "chowkidar-influxdb"

  depends_on = [aws_ecs_task_definition.chowkidar_influxdb]
}

resource "aws_ecs_service" "chowkidar_influxdb" {
  platform_version = "1.4.0"
  name    = "chowkidar-influxdb"
  cluster = module.ecs.this_ecs_cluster_id
  task_definition = "${data.aws_ecs_task_definition.chowkidar_influxdb.family}:${max(
    aws_ecs_task_definition.chowkidar_influxdb.revision,
    data.aws_ecs_task_definition.chowkidar_influxdb.revision,
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

  service_registries {
    registry_arn = aws_service_discovery_service.chowkidar_discovery_service.arn
  }

  tags = local.tags
}
