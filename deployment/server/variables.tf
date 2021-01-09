variable "assume_role_arn" {
  description = "ARN of the role to assume into"
  type        = string
}

variable "tags" {
  type        = map(string)
  description = "A map of tags to use on all resources"
}

variable "project" {
  type        = string
  description = "Name of the project"
}

variable "env" {
  type        = string
  description = "Environment in which the resources are launched (ex: prod, staging)"
}

variable "creation_date" {
  type        = string
  description = "Date at which this cluster is created"
}

variable "owner" {
  type        = string
  description = "Owner of the environment"
}

variable "vpc_id" {
  description = "ID of an existing VPC where resources will be created"
  type        = string
}

variable "public_subnet_ids" {
  description = "A list of IDs of existing public subnets inside the VPC"
  type        = list(string)
}

variable "private_subnet_ids" {
  description = "A list of IDs of existing private subnets inside the VPC"
  type        = list(string)
}

variable "alb_ingress_cidr_blocks" {
  description = "List of IPv4 CIDR ranges to use on all ingress rules of the ALB. (for ex: Office IPs)"
  type        = list(string)
}

variable "iam_instance_profile_role" {
  description = "ARN of instance profile role for ECS Clusters for the corresponding account"
  type        = string
}

variable "domain_name" {
  description = "Domain on which chowkidar will be deployed (Needed for ALB HTTPS ACM certificate)"
  type        = string
}

variable "subject_alternative_names" {
  description = "Domain on which chowkidar will be deployed (Needed for ALB HTTPS ACM certificate)"
  type        = list(string)
}

variable "chowkidar_image" {
  description = "Docker image to run Chowkidar server with. If not specified, official Innovaccer's custom atlantis image will be used"
  type        = string
  default     = "vedantrathore/chowkidar-server:latest"
}

variable "grafana_image" {
  description = "Docker image to run Grafana server with. If not specified, official image will be used"
  type        = string
  default     = "grafana/grafana:latest"
}

variable "influxdb_image" {
  description = "Docker image to run Influxdb server with. If not specified, official image will be used"
  type        = string
  default     = "influxdb:latest"
}

variable "chowkidar_version" {
  description = "Version of chowkidar to run. If not specified latest will be used"
  type        = string
  default     = "latest"
}

variable "chowkidar_port" {
  description = "Port on which chowkidar node webhook server should run"
  type        = string
}

variable "influxdb_database_name" {
  description = "Name of the influxdb database to connect"
  type        = string
}


variable "custom_environment_secrets" {
  description = "List of additional secrets the container will use (list should contain maps with `name` and `valueFrom`)"
  type = list(object(
    {
      name      = string
      valueFrom = string
    }
  ))
  default = []
}

