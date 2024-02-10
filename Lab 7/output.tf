output "instance_in_eu_west_2a" {
  value = "aws ssm start-session --target ${data.aws_instance.eu_west_2a.id}"
}

output "instance_in_eu_west_2b" {
  value = "aws ssm start-session --target ${data.aws_instance.eu_west_2b.id}"
}

output "ecs_alb_dns" {
  value = aws_lb.ecs_alb.dns_name
}

# confirm if mount is successful using the below
# df -h 
