variable "subnet_id" {
  description = "The subnet ID to deploy the instance into"
  type        = string
}

variable "security_group_id" {
  description = "The security group ID to assign to the instance"
  type        = string
}
variable "ami" {
  description = "The AMI ID for the EC2 instance"
  type        = string
}

variable "instance_type" {
  description = "The type of the EC2 instance"
  type        = string
}
