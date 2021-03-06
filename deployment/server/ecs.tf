##############################################
# ECS cluster, service discovery and IAM roles
##############################################
module "ecs" {
  source  = "terraform-aws-modules/ecs/aws"
  version = "v2.0.0"

  name = "chowkidar"

  tags = local.tags
}

data "aws_iam_policy_document" "ecs_tasks" {
  statement {
    actions = [
      "sts:AssumeRole",
    ]

    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "ecs_task_execution" {
  name               = "chowkidar-ecs_task_execution"
  assume_role_policy = data.aws_iam_policy_document.ecs_tasks.json

  tags = local.tags
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution" {
  role       = aws_iam_role.ecs_task_execution.id
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

// ref: https://docs.aws.amazon.com/AmazonECS/latest/developerguide/specifying-sensitive-data.html
data "aws_iam_policy_document" "ecs_task_access_secrets" {
  statement {
    effect = "Allow"

    resources = flatten(list(
      data.aws_ssm_parameter.influxdb_username.*.arn,
      data.aws_ssm_parameter.influxdb_password.*.arn,
      data.aws_ssm_parameter.grafana_username.*.arn,
      data.aws_ssm_parameter.grafana_password.*.arn,
      data.aws_ssm_parameter.ipstack_access_key.*.arn,
    ))

    actions = [
      "ssm:GetParameters",
      "secretsmanager:GetSecretValue",
    ]
  }
}

resource "aws_iam_role_policy" "ecs_task_access_secrets" {
  name = "ECSTaskAccessSecretsPolicy"

  role = aws_iam_role.ecs_task_execution.id

  policy = element(
    compact(
      concat(
        data.aws_iam_policy_document.ecs_task_access_secrets.*.json,
      ),
    ),
    0,
  )
}

resource "aws_service_discovery_private_dns_namespace" "chowkidar_dns_namespace" {
  name        = "chowkidar"
  description = "Private DNS namespace for chowkidar"
  vpc         = var.vpc_id
}

resource "aws_service_discovery_service" "chowkidar_discovery_service" {
  name = "internal"

  dns_config {
    namespace_id = aws_service_discovery_private_dns_namespace.chowkidar_dns_namespace.id

    dns_records {
      ttl  = 10
      type = "A"
    }

    routing_policy = "MULTIVALUE"
  }

  health_check_custom_config {
    failure_threshold = 1
  }
}
