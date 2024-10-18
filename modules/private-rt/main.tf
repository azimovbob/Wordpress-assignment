resource "aws_route_table" "default" {
  vpc_id = var.vpc_id

  route {
    cidr_block     = var.cidr_rt
    nat_gateway_id = var.nat_id
  }

  tags = {
    Name = var.rt_name
  }
}


