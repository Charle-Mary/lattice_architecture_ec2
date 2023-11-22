# resource "aws_vpclattice_service" "example" {
#   name               = "example"
#   auth_type          = "AWS_IAM"
#   custom_domain_name = "example.com"
# }


# resource "aws_vpclattice_service_network" "example" {
#   name      = "example"
#   auth_type = "AWS_IAM"
# }

# resource "aws_vpclattice_service_network_service_association" "example" {
#   service_identifier         = aws_vpclattice_service.example.id
#   service_network_identifier = aws_vpclattice_service_network.example.id
# }

# resource "aws_vpclattice_service_network_vpc_association" "example" {
#   vpc_identifier             = aws_vpc.example.id
#   service_network_identifier = aws_vpclattice_service_network.example.id
#   security_group_ids         = [aws_security_group.example.id]
# }

# resource "aws_vpclattice_target_group" "example" {
#   name = "example"
#   type = "IP"

#   config {
#     vpc_identifier = aws_vpc.example.id

#     ip_address_type  = "IPV4"
#     port             = 443
#     protocol         = "HTTPS"
#     protocol_version = "HTTP1"

#     health_check {
#       enabled                       = true
#       health_check_interval_seconds = 20
#       health_check_timeout_seconds  = 10
#       healthy_threshold_count       = 7
#       unhealthy_threshold_count     = 3

#       matcher {
#         value = "200-299"
#       }

#       path             = "/instance"
#       port             = 80
#       protocol         = "HTTP"
#       protocol_version = "HTTP1"
#     }
#   }
# }

# resource "aws_vpclattice_target_group_attachment" "example" {
#   target_group_identifier = aws_vpclattice_target_group.example.id

#   target {
#     id   = aws_lb.example.arn
#     port = 80
#   }
# }