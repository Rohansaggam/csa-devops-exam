output "private_ip" {
  description = "The private IP address of the web server"
  value       = aws_instance.web.private_ip
}
output "public_ip" {
  description = "The public IP address of the web server"
  value       = aws_instance.web.public_ip
}
output "instance_id" {
  description = "The EC2 instance ID"
  value       = aws_instance.web.id
}
