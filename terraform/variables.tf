variable "aws_region" {
  type    = string
  default = "us-east-1"
}

# Docker image info
variable "image_tag" {
  description = "Docker image tag from CI"
}

# ECS
variable "execution_role_arn" {
  description = "Existing ECS task execution role ARN"
}

variable "db_name" {}
variable "db_username" {}
variable "db_password" {}

