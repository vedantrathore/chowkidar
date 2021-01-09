locals {
  chowkidar_image = var.chowkidar_image

  ssm_path_influxdb_username  = "/chowkidar/influx/influxdb_username"
  ssm_path_influxdb_password  = "/chowkidar/influx/influxdb_password"
  ssm_path_grafana_username   = "/chowkidar/influx/grafana_username"
  ssm_path_grafana_password   = "/chowkidar/influx/grafana_password"
  ssm_path_ipstack_access_key = "/chowkidar/influx/ipstack_access_key"

  server_container_definition_environment = [
    {
      name  = "INFLUXDB_HOST"
      value = "chowkidar-server.internal.chowkidar"
    },
    {
      name  = "INFLUXDB_DATABASE"
      value = var.influxdb_database_name
    },
  ]

  server_container_definition_secrets = [
    {
      name      = "INFLUXDB_USERNAME"
      valueFrom = local.ssm_path_influxdb_username
    },
    {
      name      = "INFLUXDB_PASSWORD"
      valueFrom = local.ssm_path_influxdb_password
    },
    {
      name      = "GRAFANA_USERNAME"
      valueFrom = local.ssm_path_grafana_username
    },
    {
      name      = "GRAFANA_PASSWORD"
      valueFrom = local.ssm_path_grafana_password
    },
    {
      name      = "IPSTACK_ACCESS_KEY"
      valueFrom = local.ssm_path_ipstack_access_key
    },
  ]

  grafana_container_definition_environment = [
    {
      name  = "GF_INSTALL_PLUGINS"
      value = "grafana-worldmap-panel"
    }
  ]

  grafana_container_definition_secrets = [
    {
      name      = "GF_SECURITY_ADMIN_USER"
      valueFrom = local.ssm_path_grafana_username
    },
    {
      name      = "GF_SECURITY_ADMIN_PASSWORD"
      valueFrom = local.ssm_path_grafana_password
    }
  ]

  influxdb_container_definition_environment = [
    {
      name  = "INFLUXDB_DB"
      value = var.influxdb_database_name
    }
  ]

  influxdb_container_definition_secrets = [
    {
      name      = "INFLUXDB_ADMIN_USER"
      valueFrom = local.ssm_path_influxdb_username
    },
    {
      name      = "INFLUXDB_ADMIN_PASSWORD"
      valueFrom = local.ssm_path_influxdb_password
    }
  ]

  tags = merge(
    {
      "Name" = "chowkidar"
    },
    var.tags,
  )
}

data "aws_region" "current" {}
