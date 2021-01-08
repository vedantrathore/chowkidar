###################
# Security groups
###################
module "alb_https_sg" {
  source  = "terraform-aws-modules/security-group/aws//modules/https-443"
  version = "v3.9.0"

  name        = "chowkidar-alb-https"
  vpc_id      = var.vpc_id
  description = "Security group with HTTPS ports open for specific IPv4 CIDR block (or everybody), egress ports are all world open"

  ingress_cidr_blocks = var.alb_ingress_cidr_blocks

  tags = local.tags
}

module "alb_http_sg" {
  source  = "terraform-aws-modules/security-group/aws//modules/http-80"
  version = "v3.9.0"

  name        = "chowkidar-alb-http"
  vpc_id      = var.vpc_id
  description = "Security group with HTTP ports open for specific IPv4 CIDR block (or everybody), egress ports are all world open"

  ingress_cidr_blocks = var.alb_ingress_cidr_blocks

  tags = local.tags
}

module "chowkidar_sg" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "v3.9.0"

  name        = "chowkidar"
  vpc_id      = var.vpc_id
  description = "Security group with open port for chowkidar (${var.chowkidar_port}) from ALB, egress ports are all world open"

  ingress_with_source_security_group_id = [
    {
      from_port                = var.chowkidar_port
      to_port                  = var.chowkidar_port
      protocol                 = "tcp"
      description              = "Chowkidar webhook server"
      source_security_group_id = module.alb_https_sg.this_security_group_id
    },
    {
      from_port                = 3000
      to_port                  = 3000
      protocol                 = "tcp"
      description              = "Chowkidar grafana dashboard"
      source_security_group_id = module.alb_https_sg.this_security_group_id
    },
  ]

  egress_rules = ["all-all"]

  tags = local.tags
}

module "efs_sg" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "v3.9.0"

  name        = "chowkidar-efs"
  vpc_id      = var.vpc_id
  description = "Security group with open port for NFS from Grafana/InfluxDB, egress ports are all world open"

  ingress_with_source_security_group_id = [
    {
      from_port                = 2049
      to_port                  = 2049
      protocol                 = "tcp"
      description              = "Chowkidar EFS NFS port"
      source_security_group_id = module.alb_https_sg.this_security_group_id
    },
  ]

  egress_rules = ["all-all"]

  tags = local.tags
}
