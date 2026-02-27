data "aws_vpc" "default" {
  default = true
}

data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

resource "aws_ecs_cluster" "jaspal_task11_cluster" {
  name = "jaspal-task11-strapi-cluster"
}

resource "aws_ecs_task_definition" "jaspal_task11_task" {
  family                   = "jaspal-task11-strapi-task"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "512"
  memory                   = "1024"
  execution_role_arn       = var.execution_role_arn

  container_definitions = jsonencode([
    {
      name  = "jaspal-task11-strapi-container"
      image = "${var.ecr_repository_url}:${var.image_tag}"

      portMappings = [
        {
          containerPort = 1337
          protocol      = "tcp"
        }
      ]

      environment = [
        { name = "HOST", value = "0.0.0.0" },
        { name = "PORT", value = "1337" },

        { name = "DATABASE_CLIENT", value = "postgres" },
        { name = "DATABASE_HOST", value = var.db_host },
        { name = "DATABASE_PORT", value = "5432" },
        { name = "DATABASE_NAME", value = var.db_name },
        { name = "DATABASE_USERNAME", value = var.db_username },
        { name = "DATABASE_PASSWORD", value = var.db_password },
        { name = "DATABASE_SSL", value = "false" },
        { name = "DATABASE_SSL_REJECT_UNAUTHORIZED", value = "false" },
        { name = "NODE_TLS_REJECT_UNAUTHORIZED", value = "0" },

        { name = "APP_KEYS", value = "key1,key2,key3,key4" },
        { name = "API_TOKEN_SALT", value = "api_token_salt_123" },
        { name = "ADMIN_JWT_SECRET", value = "admin_jwt_secret_123" },
        { name = "JWT_SECRET", value = "jwt_secret_123" },
        { name = "TRANSFER_TOKEN_SALT", value = "transfer_token_salt_123" },
        { name = "ENCRYPTION_KEY", value = "encryption_key_1234567890" }

      ]
    }
  ])
}

resource "aws_security_group" "ecs_sg" {
  name   = "jaspal-task11-ecs-sg"
  vpc_id = data.aws_vpc.default.id

  ingress {
    from_port       = 1337
    to_port         = 1337
    protocol        = "tcp"
    security_groups = [var.alb_sg_id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_ecs_service" "jaspal_task11_service" {
  name            = "jaspal-task11-strapi-service"
  cluster         = aws_ecs_cluster.jaspal_task11_cluster.id
  task_definition = aws_ecs_task_definition.jaspal_task11_task.arn
  desired_count   = 1 
  capacity_provider_strategy {
    capacity_provider = "FARGATE"
    weight            = 1
  }

  deployment_controller {
  type = "CODE_DEPLOY"
  }

  network_configuration {
    subnets          = data.aws_subnets.default.ids
    assign_public_ip = true
    security_groups = [ aws_security_group.ecs_sg.id ]
  }

  load_balancer {
  target_group_arn = var.target_group_arn
  container_name   = "jaspal-task11-strapi-container"
  container_port   = 1337
  }

  lifecycle {
  ignore_changes = [
    task_definition,
    network_configuration,
    load_balancer
  ]
}
}
