#####################
# Secrets Management
# Currently using AWS SSM for storing secrets but need to migrate to Hashicorp Vault
#####################
data "aws_ssm_parameter" "influxdb_username" {
  name = local.ssm_path_influxdb_username
}

data "aws_ssm_parameter" "influxdb_password" {
  name = local.ssm_path_influxdb_password
}

data "aws_ssm_parameter" "grafana_username" {
  name = local.ssm_path_grafana_username
}

data "aws_ssm_parameter" "grafana_password" {
  name = local.ssm_path_grafana_password
}

data "aws_ssm_parameter" "ipstack_access_key" {
  name = local.ssm_path_ipstack_access_key
}
