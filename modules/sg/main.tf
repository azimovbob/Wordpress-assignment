resource "aws_security_group" "default" {
  name        = var.sg_name
  description = "Allow inbound traffic and all outbound traffic"
  vpc_id      = var.vpc_id

  tags = {
    Name = var.sg_name
  }

  dynamic "ingress" {
    for_each = var.ingress_ports
    content {
      from_port       = ingress.value
      to_port         = ingress.value
      protocol        = var.protocol
      cidr_blocks     = var.cidr_block_sg
      security_groups = var.security_groups
    }
  }

  dynamic "egress" {
    for_each = var.egress_ports
    content {
      from_port   = egress.value
      to_port     = egress.value
      protocol    = var.egress_protocol
      cidr_blocks = ["0.0.0.0/0"]
    }
  }

}
