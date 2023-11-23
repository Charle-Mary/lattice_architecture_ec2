output "service_domain" {
  value = aws_vpclattice_service.destination_service.dns_entry
}