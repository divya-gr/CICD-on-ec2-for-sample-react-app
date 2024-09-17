variable "subnet_id" {
  description = "The subnet ID to deploy the instance into"
  type        = string
}

variable "security_group_id" {
  description = "The security group ID to assign to the instance"
  type        = string
}

variable "vpc_cidr" {
  description = "The CIDR block for the VPC"
  type        = string

}

variable "vpc_name" {
  description = "The name of the VPC"
  type        = string
  default     = "vpc-testing"
}

variable "subnet_cidr" {
  description = "The CIDR block for the subnet"
  type        = string
}

variable "availability_zone" {
  description = "The availability zone for the subnet"
  type        = string
}

variable "subnet_name" {
  description = "The name of the subnet"
  type        = string
 
}

variable "security_group_name" {
  description = "The name of the security group"
  type        = string
}
