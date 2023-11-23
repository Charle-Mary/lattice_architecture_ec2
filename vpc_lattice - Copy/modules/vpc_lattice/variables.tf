variable "source_vpc_id" {
  description = "VPC ID of the source"
}

variable "destination_vpc_id" {
  description = "VPC ID of the destination"
}

variable "instance_id" {
  description = "Destination ec2 instance id"
}

variable "source_security_group" {
  description = "Security group used by the source VPC on the service network"
}