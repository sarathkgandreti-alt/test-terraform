output "linux_instance_ip" {
  description = "Public IP of Linux instance"
  value       = aws_instance.linux_instance.public_ip
}

output "linux_instance_private_ip" {
  description = "Private IP of Linux instance"
  value       = aws_instance.linux_instance.private_ip
}

output "windows_instance_ip" {
  description = "Public IP of Windows instance"
  value       = aws_instance.windows_instance.public_ip
}

output "windows_instance_private_ip" {
  description = "Private IP of Windows instance"
  value       = aws_instance.windows_instance.private_ip
}

output "peering_connection_id" {
  description = "ID of the VPC peering connection"
  value       = aws_vpc_peering_connection.peering.id
}
