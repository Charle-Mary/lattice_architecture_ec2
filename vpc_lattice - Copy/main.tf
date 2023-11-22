module "vpc" {
  source = "./modules/vpc"

  vpc_parameters = {
    vpc1 = {
      cidr_block = "10.0.0.0/16"
    }
  }
  subnet_parameters = {
    subnet1 = {
      cidr_block = "10.0.1.0/24"
      vpc_name   = "vpc1"
    },
    subnet2 = {
      cidr_block = "10.0.2.0/24"
      vpc_name   = "vpc1"
    }
  }
  igw_parameters = {
    igw1 = {
      vpc_name = "vpc1"
    }
  }
  rt_parameters = {
    rt1 = {
      vpc_name = "vpc1"
      routes = [{
        cidr_block = "0.0.0.0/0"
        gateway_id = "igw1"
      }]
    }
  }
  rt_association_parameters = {
    assoc1 = {
      subnet_name = "subnet1"
      rt_name     = "rt1"
    },
    assoc2 = {
      subnet_name = "subnet2"
      rt_name     = "rt1"
    }
  }
}


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




