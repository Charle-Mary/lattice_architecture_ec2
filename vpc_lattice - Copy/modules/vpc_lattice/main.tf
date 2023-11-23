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

# Target group for the destination service
resource "aws_vpclattice_target_group" "ec2_group" {
  name = "instances"
  type = "INSTANCE"
  config {
    port           = 80
    protocol       = "HTTP"
    vpc_identifier = var.destination_vpc_id
    health_check {
      enabled                       = true
      health_check_interval_seconds = 30
      health_check_timeout_seconds  = 5
      healthy_threshold_count       = 5
      unhealthy_threshold_count     = 2
      matcher {
        value = "200"
      }
      path             = "/"
      port             = 80
      protocol         = "HTTP"
      protocol_version = "HTTP1"
    }
  }
}

resource "aws_vpclattice_target_group_attachment" "ec2_group_attachment" {
  target_group_identifier = aws_vpclattice_target_group.ec2_group.id
  target {
    id   = var.instance_id
    port = 80
  }
}

# Destination service
resource "aws_vpclattice_service" "destination_service" {
  name      = "apache-web"
  auth_type = "NONE"
}

# Listener for the destination service component
resource "aws_vpclattice_listener" "destination_service_listener" {
  name               = "apache-web-listener"
  protocol           = "HTTP"
  service_identifier = aws_vpclattice_service.destination_service.id
  default_action {
    forward {
      target_groups {
        target_group_identifier = aws_vpclattice_target_group.ec2_group.id
      }
    }
  }
}

# Service network for managing all lattice component VPCs and services
resource "aws_vpclattice_service_network" "service_network" {
  name      = "servnet"
  auth_type = "NONE"
}

# Destination service association with service network
resource "aws_vpclattice_service_network_service_association" "service_association" {
  service_identifier         = aws_vpclattice_service.destination_service.id
  service_network_identifier = aws_vpclattice_service_network.service_network.id
}

# Source VPC association with service network
resource "aws_vpclattice_service_network_vpc_association" "vpc_association" {
  vpc_identifier             = var.source_vpc_id
  service_network_identifier = aws_vpclattice_service_network.service_network.id
  security_group_ids         = [var.source_security_group]
}
