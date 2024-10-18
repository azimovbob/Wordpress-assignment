resource "aws_nat_gateway" "default" {
  allocation_id = aws_eip.lb.allocation_id
  subnet_id     = var.subnet_id

  tags = {
    Name = var.nat_name
  }

}

resource "aws_eip" "lb" {
  domain = "vpc"
}
