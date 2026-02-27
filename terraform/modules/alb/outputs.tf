output "alb_arn" {
  value = aws_lb.alb.arn
}

output "blue_tg_arn" {
  value = aws_lb_target_group.blue.arn
}

output "green_tg_arn" {
  value = aws_lb_target_group.green.arn
}

output "alb_sg_id" {
  value = aws_security_group.alb_sg.id
}

output "listener_arn" {
  value = aws_lb_listener.listener.arn
}