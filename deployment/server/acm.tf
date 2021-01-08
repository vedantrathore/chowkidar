###################
# ACM (SSL certificate)
###################
module "acm" {
  source  = "terraform-aws-modules/acm/aws"
  version = "v2.5.0"

  create_certificate   = true
  validate_certificate = false

  domain_name = var.domain_name

  subject_alternative_names = var.subject_alternative_names

  tags = local.tags
}
