
module "vpc" {
  source = "../VPC"
  subnet_id         = module.vpc.subnet_id
  security_group_id = module.vpc.security_group_id 
  vpc_cidr           = var.vpc_cidr
  vpc_name           = var.vpc_name
  subnet_cidr        = var.subnet_cidr
  availability_zone  = var.availability_zone
  subnet_name        = var.subnet_name
  security_group_name = var.security_group_name
}

module "ec2" {
  source            = "../EC2"
  subnet_id         = module.vpc.subnet_id
  security_group_id = module.vpc.security_group_id
  ami               = var.ami
  instance_type     = var.instance_type
}
