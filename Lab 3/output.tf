output "ec2_public_ip" {
  value = "http://${aws_instance.Linux.public_ip}"
}