output "source_vpc_id" {
  value = aws_vpc.source_vpc.id
}
output "destination_vpc_id" {
  description = "VPC Outputs"
  value       = aws_vpc.destination_vpc.id
}
output "destination_private_subnet_id" {
  value = aws_subnet.destination_priv_subnet.id
}

output "destination_public_subnet_id" {
  value = aws_subnet.destination_pub_subnet.id
}

output "source_public_subnet_id" {
  value = aws_subnet.source_pub_subnet.id
}





