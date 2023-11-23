#module "vpc" {
#  source = "./modules/vpc"
#
#  vpc_parameters = {
#    vpc1 = {
#      cidr_block = "10.0.0.0/16"
#    }
#  }
#  subnet_parameters = {
#    subnet1 = {
#      cidr_block = "10.0.1.0/24"
#      vpc_name   = "vpc1"
#    },
#    subnet2 = {
#      cidr_block = "10.0.2.0/24"
#      vpc_name   = "vpc1"
#    }
#  }
#  igw_parameters = {
#    igw1 = {
#      vpc_name = "vpc1"
#    }
#  }
#  rt_parameters = {
#    rt1 = {
#      vpc_name = "vpc1"
#      routes = [{
#        cidr_block = "0.0.0.0/0"
#        gateway_id = "igw1"
#      }]
#    }
#  }
#  rt_association_parameters = {
#    assoc1 = {
#      subnet_name = "subnet1"
#      rt_name     = "rt1"
#    },
#    assoc2 = {
#      subnet_name = "subnet2"
#      rt_name     = "rt1"
#    }
#  }
#}
#

# module "ec2_instances" {
#   source = "./modules/ec2"

#   instance_details = [
#     {
#       instance_type = var.instance_type
#       subnet_id     = module.vpc.subnet_ids_list[0]
#       name          = "Instance1"
#     },
#     {
#       instance_type = var.instance_type
#       subnet_id     = module.vpc.subnet_ids_list[1]
#       name          = "Instance2"
#     }
#   ]
# }


# Create VPC and its components
module "vpc" {
  source = "./modules/vpc"
}

# Create client and destination instances in their respective VPCs
module "ec2" {
  source                = "./modules/ec2"
  destination_vpc_id    = module.vpc.destination_vpc_id
  destination_subnet_id = module.vpc.destination_private_subnet_id
  source_vpc_id         = module.vpc.source_vpc_id
  source_subnet_id      = module.vpc.source_public_subnet_id
}

# Create the service network and other components of the lattice architecture
module "vpc_lattice" {
  source                = "./modules/vpc_lattice"
  source_vpc_id         = module.vpc.source_vpc_id
  destination_vpc_id    = module.vpc.destination_vpc_id
  instance_id           = module.ec2.destination_instance_id
  source_security_group = module.ec2.source_instance_security_group
}
