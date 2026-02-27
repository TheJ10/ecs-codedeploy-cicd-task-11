resource "aws_codedeploy_app" "ecs_app" {
  name             = "jaspal-task11-codedeploy-app"
  compute_platform = "ECS"
}

resource "aws_codedeploy_deployment_group" "ecs_dg" {
  app_name               = aws_codedeploy_app.ecs_app.name
  deployment_group_name  = "jaspal-task11-dg"
  service_role_arn = "arn:aws:iam::811738710312:role/codedeploy_role"
  deployment_config_name = "CodeDeployDefault.ECSCanary10Percent5Minutes"

  auto_rollback_configuration {
    enabled = true
    events  = ["DEPLOYMENT_FAILURE"]
  }

  deployment_style {
    deployment_type   = "BLUE_GREEN"
    deployment_option = "WITH_TRAFFIC_CONTROL"
  }

  ecs_service {
    cluster_name = var.ecs_cluster_name
    service_name = var.ecs_service_name
  }

  load_balancer_info {
    target_group_pair_info {
      target_group {
        name = split("/", var.blue_tg_arn)[1]
      }

      target_group {
        name = split("/", var.green_tg_arn)[1]
      }

      prod_traffic_route {
        listener_arns = [var.listener_arn]
      }
    }
  }

  blue_green_deployment_config {
    
    deployment_ready_option {
      action_on_timeout    = "CONTINUE_DEPLOYMENT"
      wait_time_in_minutes = 0
    }

    terminate_blue_instances_on_deployment_success {
      action = "TERMINATE"
      termination_wait_time_in_minutes = 5
    }
  }
}