output "ecs_task_public_ip" {
    value = "http://${data.aws_network_interface.ecs_task_interface.association[0].public_ip}"
}

output "alb_dns" {
  value = aws_lb.alb.dns_name
}

output "ecs_execute_command" {
  value = <<-COMMAND
    aws ecs execute-command \
        --cluster ${var.ecs_cluster_name} \
        --task $task_id \
        --container ${var.container_name} \
        --interactive \
        --command "/bin/sh"
  COMMAND
}

