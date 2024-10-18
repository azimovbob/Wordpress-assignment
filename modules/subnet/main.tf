resource "aws_subnet" "default" {
  vpc_id                  = var.vpc_id
  cidr_block              = var.cidr_subnet
  map_public_ip_on_launch = var.assign_public_ip
  availability_zone       = var.az
  tags = {
    Name = var.subnet_name
  }

}


