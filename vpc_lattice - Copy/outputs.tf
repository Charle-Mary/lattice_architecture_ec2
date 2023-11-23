output "ec2_login" {
  value = module.ec2.spurce_ec2_login
}

output "service_domain" {
  value = module.vpc_lattice.service_domain
}