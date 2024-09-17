ami           = "ami-0e86e20dae9224db8" # Use a suitable AMI for your region
instance_type = "t2.micro"
vpc_cidr = "10.0.0.0/16"
vpc_name = "vpc-testing"

# Subnet variables
subnet_cidr = "10.0.1.0/24"
availability_zone = "us-east-1a"
subnet_name = "subnet-testing"

# Security Group variables
security_group_name = "main-sg"
