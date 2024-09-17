
resource "aws_instance" "main" {
  ami= var.ami
  instance_type = var.instance_type
  associate_public_ip_address = true

  subnet_id       = var.subnet_id
  security_groups = [var.security_group_id]
  tags = {
    Name = "main-ec2"
  }
}
