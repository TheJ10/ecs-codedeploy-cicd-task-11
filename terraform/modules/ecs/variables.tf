variable "image_tag" {}
variable "ecr_repository_url" {
  type = string
}

variable "execution_role_arn" {}

variable "aws_region" {
  type = string
}

variable "db_host" {}
variable "db_name" {}
variable "db_username" {}
variable "db_password" {}

variable "target_group_arn" {
  type = string
}

variable "alb_sg_id" {
  type = string
}