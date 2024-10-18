resource "aws_vpc" "default" {
  cidr_block       = var.cidr_vpc

  tags = {
    Name = var.vpc_name
  }
}