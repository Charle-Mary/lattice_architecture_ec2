output "destination_instance_id" {
  value = aws_instance.destination_instance.id
}

output "source_instance_security_group" {
  value = aws_security_group.allow_public_traffic.id
}

output "spurce_ec2_login" {
  value = "ssh -i ${var.key_name}.pem ec2-user@${aws_instance.source_instance.public_ip}"
}
