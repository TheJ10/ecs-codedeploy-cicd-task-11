data "aws_vpc" "default" {
  default = true
}

data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }

  filter {
    name   = "default-for-az"
    values = ["true"]
  }
}

resource "aws_security_group" "rds_sg" {
  name   = "jaspal-task11-rds-sg"
  vpc_id = data.aws_vpc.default.id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

module "ecs_jaspal_task11" {
  source = "./modules/ecs"
  image_tag           = var.image_tag
  ecr_repository_url = module.ecr_jaspal_task11.repository_url
  execution_role_arn = var.execution_role_arn
  aws_region     = var.aws_region

  db_host     = module.rds_jaspal_task11.db_endpoint
  db_name     = var.db_name
  db_username = var.db_username
  db_password = var.db_password

  target_group_arn = module.alb_jaspal_task11.blue_tg_arn
  alb_sg_id        = module.alb_jaspal_task11.alb_sg_id

}

module "rds_jaspal_task11" {
  source     = "./modules/rds"
  subnet_ids = data.aws_subnets.default.ids

  db_name     = var.db_name
  db_username = var.db_username
  db_password = var.db_password

  rds_sg_id = aws_security_group.rds_sg.id
}

module "ecr_jaspal_task11" {
  source = "./modules/ecr"
}

module "alb_jaspal_task11" {
  source     = "./modules/alb"
  vpc_id     = data.aws_vpc.default.id
  subnet_ids = data.aws_subnets.default.ids
}

module "codedeploy_jaspal_task11" {
  source = "./modules/codedeploy"

  ecs_cluster_name = module.ecs_jaspal_task11.cluster_name
  ecs_service_name = module.ecs_jaspal_task11.service_name

  blue_tg_arn  = module.alb_jaspal_task11.blue_tg_arn
  green_tg_arn = module.alb_jaspal_task11.green_tg_arn
  listener_arn = module.alb_jaspal_task11.listener_arn
}

resource "aws_security_group_rule" "allow_ecs_to_rds" {
  type                     = "ingress"
  from_port                = 5432
  to_port                  = 5432
  protocol                 = "tcp"
  security_group_id        = aws_security_group.rds_sg.id
  source_security_group_id = module.ecs_jaspal_task11.ecs_sg_id
}