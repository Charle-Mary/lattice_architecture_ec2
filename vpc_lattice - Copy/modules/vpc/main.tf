#resource "aws_vpc" "this" {
#  for_each             = var.vpc_parameters
#  cidr_block           = each.value.cidr_block
#  enable_dns_support   = each.value.enable_dns_support
#  enable_dns_hostnames = each.value.enable_dns_hostnames
#  tags = merge(each.value.tags, {
#    Name : each.key
#  })
#}
#
#resource "aws_subnet" "this" {
#  for_each   = var.subnet_parameters
#  vpc_id     = aws_vpc.this[each.value.vpc_name].id
#  cidr_block = each.value.cidr_block
#  tags = merge(each.value.tags, {
#    Name : each.key
#  })
#}
#
#resource "aws_internet_gateway" "this" {
#  for_each = var.igw_parameters
#  vpc_id   = aws_vpc.this[each.value.vpc_name].id
#  tags = merge(each.value.tags, {
#    Name : each.key
#  })
#}
#
#resource "aws_route_table" "this" {
#  for_each = var.rt_parameters
#  vpc_id   = aws_vpc.this[each.value.vpc_name].id
#  tags = merge(each.value.tags, {
#    Name : each.key
#  })
#
#  dynamic "route" {
#    for_each = each.value.routes
#    content {
#      cidr_block = route.value.cidr_block
#      gateway_id = route.value.use_igw ? aws_internet_gateway.this[route.value.gateway_id].id : route.value.gateway_id
#    }
#  }
#}
#
#resource "aws_route_table_association" "this" {
#  for_each       = var.rt_association_parameters
#  subnet_id      = aws_subnet.this[each.value.subnet_name].id
#  route_table_id = aws_route_table.this[each.value.rt_name].id
#}

# Source VPC where client ec2 instance is provisioned
resource "aws_vpc" "source_vpc" {
  cidr_block = var.source_cidr
  tags = {
    Name = "source_vpc"
  }
}

# Destination VPC where web server is provisioned
resource "aws_vpc" "destination_vpc" {
  cidr_block = var.destination_cidr
  tags = {
    Name = "destination_vpc"
  }
}

# Public subnet where client instance is provisioned
resource "aws_subnet" "source_pub_subnet" {
  vpc_id     = aws_vpc.source_vpc.id
  cidr_block = var.source_pub_subnet_cidr
  tags = {
    Name = "source_pub_subnet"
  }
}

# Destination public subnet where nat gateway is provisioned
resource "aws_subnet" "destination_pub_subnet" {
  vpc_id     = aws_vpc.destination_vpc.id
  cidr_block = var.destination_pub_subnet_cidr
  tags = {
    Name = "destination_pub_subnet"
  }
}

# Subnet where web server is provisioned
resource "aws_subnet" "destination_priv_subnet" {
  vpc_id     = aws_vpc.destination_vpc.id
  cidr_block = var.destination_priv_subnet_cidr
  tags = {
    Name = "destination_priv_subnet"
  }
}


# CLient VPC internet gateway
resource "aws_internet_gateway" "source_igw" {
  vpc_id = aws_vpc.source_vpc.id
  tags = {
    Name = "source_vpc_igw"
  }
}

# Destination VPC internet gateway
resource "aws_internet_gateway" "destination_igw" {
  vpc_id = aws_vpc.destination_vpc.id
  tags = {
    Name = "destination_vpc_igw"
  }
}

resource "aws_eip" "nat_eip" {
  domain = "vpc"
}

resource "aws_nat_gateway" "ngw" {
  allocation_id = aws_eip.nat_eip.allocation_id
  subnet_id     = aws_subnet.destination_pub_subnet.id
  tags = {
    Name = "destination_public_ngw"
  }
}

resource "aws_route_table" "source_pub_route_table" {
  vpc_id = aws_vpc.source_vpc.id
  route {
    cidr_block = var.public_traffic
    gateway_id = aws_internet_gateway.source_igw.id
  }
  tags = {
    Name = "source_pub_rt"
  }
}

resource "aws_route_table" "destination_pub_route_table" {
  vpc_id = aws_vpc.destination_vpc.id
  route {
    cidr_block = var.public_traffic
    gateway_id = aws_internet_gateway.destination_igw.id
  }
  tags = {
    Name = "destination_pub_rt"
  }
}

resource "aws_route_table" "destination_priv_route_table" {
  vpc_id = aws_vpc.destination_vpc.id
  route {
    cidr_block     = var.public_traffic
    nat_gateway_id = aws_nat_gateway.ngw.id
  }
  tags = {
    Name = "destination_priv_rt"
  }
}

resource "aws_route_table_association" "source_pub_subnet_rt_association" {
  route_table_id = aws_route_table.source_pub_route_table.id
  subnet_id      = aws_subnet.source_pub_subnet.id
}

resource "aws_route_table_association" "destination_priv_subnet_rt_association" {
  route_table_id = aws_route_table.destination_priv_route_table.id
  subnet_id      = aws_subnet.destination_priv_subnet.id
}

resource "aws_route_table_association" "destination_pub_subnet_rt_association" {
  route_table_id = aws_route_table.destination_pub_route_table.id
  subnet_id      = aws_subnet.destination_pub_subnet.id
}