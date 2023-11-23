variable "application_port" {
  description = "Port which application receives traffic on"
  default     = 80
}

variable "instance_type" {
  description = "EC2 instance type"
  default     = "t2.micro"
}

variable "key_name" {
  description = "SSH private key name"
  default     = "bugtrackapp"
}

variable "source_ec2_tag" {
  description = "EC2 instance name"
  default     = "source_ec2"
}

variable "destination_ec2_tag" {
  description = "EC2 instance name"
  default     = "destination_ec2"
}

variable "source_subnet_id" {
  description = "Subnet ID where source instance should be created"
}

variable "destination_subnet_id" {
  description = "Subnet ID where instance should be created"
}

variable "destination_vpc_id" {
  description = "Destination VPC id"
}

variable "source_vpc_id" {
  description = "Source VPC id"
}