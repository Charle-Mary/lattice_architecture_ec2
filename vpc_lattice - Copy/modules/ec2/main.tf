#data "aws_ami" "latest_ubuntu" {
#  most_recent = true
#
#  filter {
#    name   = "name"
#    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
#  }
#
#  filter {
#    name   = "virtualization-type"
#    values = ["hvm"]
#  }
#
#  owners = ["099720109477"] # Canonical
#}
#
#resource "aws_instance" "example" {
#  count = length(var.instance_details)
#
#  ami           = data.aws_ami.latest_ubuntu.id
#  instance_type = "t2.micro"
#  subnet_id     = var.instance_details[count.index]["subnet_id"]
#
#  tags = {
#    Name = var.instance_details[count.index]["name"]
#  }
#}

# Get personal IP to be used to ssh into the client instance
data "http" "current_ip" {
  url = "http://ifconfig.me/ip"
}

# Get AMI ID of amazon linux 2 2023 version
data "aws_ami" "ami_id" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-2023*"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# Get prefix list ID of the vpc lattice service which would be given sole access to the destination EC2 instance
data "aws_ec2_managed_prefix_list" "lattice_service_prefix_list" {
  filter {
    name   = "prefix-list-name"
    values = ["com.amazonaws.eu-west-2.vpc-lattice"]
  }
}

# Security group to allow traffic from vpc lattice service
resource "aws_security_group" "allow_lattice_service_traffic" {
  name   = "Allow traffic from lattice service"
  vpc_id = var.destination_vpc_id
  ingress {
    description     = "TCP from lattice service"
    from_port       = var.application_port
    to_port         = var.application_port
    protocol        = "TCP"
    prefix_list_ids = [data.aws_ec2_managed_prefix_list.lattice_service_prefix_list.id]
  }

  egress {
    description = "Allows downloading of packages and libraries"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "allow lattice service"
  }
}

# Security group to allow traffic from personal IP and public traffic on port 80
resource "aws_security_group" "allow_public_traffic" {
  name   = "Allow traffic from public"
  vpc_id = var.source_vpc_id

  ingress {
    description = "TCP from lattice service"
    from_port   = var.application_port
    to_port     = var.application_port
    protocol    = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "TCP"
    cidr_blocks = ["${data.http.current_ip.response_body}/32"]
  }

  egress {
    description = "Allows downloading of packages and libraries"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "allow public traffic"
  }
}

# Client EC2 instance created in the source VPC
resource "aws_instance" "source_instance" {
  ami                         = data.aws_ami.ami_id.image_id
  instance_type               = var.instance_type
  key_name                    = var.key_name
  subnet_id                   = var.source_subnet_id
  associate_public_ip_address = true

  root_block_device {
    volume_size           = 28 # size in GBs
    volume_type           = "gp3"
    delete_on_termination = true
  }

  vpc_security_group_ids = [aws_security_group.allow_public_traffic.id]

  tags = {
    Name = var.source_ec2_tag
  }
}

# Destination EC2 instance created in destination VPC
resource "aws_instance" "destination_instance" {
  ami                         = data.aws_ami.ami_id.image_id
  instance_type               = var.instance_type
  subnet_id                   = var.destination_subnet_id
  associate_public_ip_address = false

  root_block_device {
    volume_size           = 28 # size in GBs
    volume_type           = "gp3"
    delete_on_termination = true
  }

  vpc_security_group_ids = [aws_security_group.allow_lattice_service_traffic.id]

  # Script to create simple web server on the destination ec2 instance
  user_data = <<EOF
#!/bin/bash
sudo yum update -y
sudo yum install httpd -y
sudo systemctl start httpd
sudo systemctl enable httpd
sudo chmod 777 /var/www/html
echo -e '<!DOCTYPE html>
<html>
  <head>
    <title>Apache Web Server</title>
  </head>
  <body>
    <h1>Apache Web Server</h1>
    <p>This is a simple HTML web page.</p>
  </body>
</html>' > /var/www/html/index.html
EOF


  tags = {
    Name = var.destination_ec2_tag
  }
}