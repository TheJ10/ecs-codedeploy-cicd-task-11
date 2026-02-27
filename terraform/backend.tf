terraform {
  backend "s3" {
    bucket = "jaspal-task11-terraform-state"
    key    = "task-11-ecs-codedeploy-cicd/terraform.tfstate"
    region = "us-east-1"
  }
}