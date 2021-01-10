###################
# ALB
###################
module "alb" {
  source  = "terraform-aws-modules/alb/aws"
  version = "5.10.0"

  name     = "chowkidar"
  internal = false

  vpc_id          = var.vpc_id
  subnets         = var.public_subnet_ids
  security_groups = flatten([module.alb_https_sg.this_security_group_id, module.alb_http_sg.this_security_group_id])

  http_tcp_listeners = [
    {
      port        = 80
      protocol    = "HTTP"
      action_type = "redirect"
      redirect = {
        port        = 443
        protocol    = "HTTPS"
        status_code = "HTTP_301"
      }
    },
  ]

  https_listeners = [
    {
      target_group_index = 0
      port               = 443
      protocol           = "HTTPS"
      certificate_arn    = module.acm.this_acm_certificate_arn
    }
  ]

  https_listener_rules = [
    {
      https_listener_index = 0
      priority             = 5000
      actions = [
        {
          type               = "forward"
          target_group_index = 0
        }
      ]
      conditions = [{
        path_patterns = ["/webhook"]
      }]
    },
    {
      https_listener_index = 0
      actions = [
        {
          type               = "forward"
          target_group_index = 1
        }
      ]
      conditions = [{
        path_patterns = ["/"]
      }]
    }
  ]

  target_groups = [
    {
      name                 = "chowkidar-server"
      backend_protocol     = "HTTP"
      backend_port         = var.chowkidar_port
      target_type          = "ip"
      deregistration_delay = 10
    },
    {
      name                 = "chowkidar-grafana"
      backend_protocol     = "HTTP"
      backend_port         = 3000
      target_type          = "ip"
      deregistration_delay = 10
    }
  ]

  tags = local.tags
}
