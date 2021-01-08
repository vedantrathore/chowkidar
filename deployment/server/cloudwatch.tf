###################
# Cloudwatch logs
###################
resource "aws_cloudwatch_log_group" "chowkidar_server" {
  name              = "chowkidar-server"
  retention_in_days = 7

  tags = local.tags
}

resource "aws_cloudwatch_log_group" "chowkidar_grafana" {
  name              = "chowkidar-grafana"
  retention_in_days = 7

  tags = local.tags
}

resource "aws_cloudwatch_log_group" "chowkidar_influxdb" {
  name              = "chowkidar-influxdb"
  retention_in_days = 7

  tags = local.tags
}


resource "aws_efs_file_system" "ecs_service_storage" {
  tags = {
    Name = "${var.service_name}-efs"
  }
}
