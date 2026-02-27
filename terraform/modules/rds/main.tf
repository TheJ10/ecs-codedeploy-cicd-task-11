data "aws_vpc" "default" {
  default = true
}

resource "aws_db_subnet_group" "jaspal_task11_db_subnet_group" {
  name       = "jaspal-task11-db-subnet-group"
  subnet_ids = var.subnet_ids
}

resource "aws_db_instance" "jaspal_task11_db" {
  identifier              = "jaspal-task11-strapi-db"
  engine                  = "postgres"
  engine_version          = "15"
  instance_class          = "db.t3.small"
  allocated_storage       = 20

  db_name                 = var.db_name
  username                = var.db_username
  password                = var.db_password

  publicly_accessible     = true
  skip_final_snapshot     = true
  deletion_protection     = false

  vpc_security_group_ids = [var.rds_sg_id]
  db_subnet_group_name    = aws_db_subnet_group.jaspal_task11_db_subnet_group.name
}
