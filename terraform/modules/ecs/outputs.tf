output "cluster_name" {
  value = aws_ecs_cluster.jaspal_task11_cluster.name
}

output "service_name" {
  value = aws_ecs_service.jaspal_task11_service.name
}

output "ecs_sg_id" {
  value = aws_security_group.ecs_sg.id
}