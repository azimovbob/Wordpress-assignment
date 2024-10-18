resource "aws_route_table" "default" {
  vpc_id = var.vpc_id

  route {
    cidr_block = var.cidr_rt
    gateway_id = var.iwg_id
  }

  tags = {
    Name = var.rt_name
  }
}
