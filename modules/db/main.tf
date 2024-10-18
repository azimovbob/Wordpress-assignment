resource "aws_db_instance" "default" {
  allocated_storage      = var.db_storage
  identifier             = var.db_name
  db_name                = var.db_name
  engine                 = var.db_engine
  engine_version         = var.db_engine_version
  instance_class         = var.db_instance_class
  username               = var.username
  password               = var.password
  parameter_group_name   = "default.mysql8.0"
  db_subnet_group_name   = aws_db_subnet_group.default.id
  skip_final_snapshot    = true
  vpc_security_group_ids = var.security_groups

  tags = {
    name = "Database"
  }
}

resource "aws_db_subnet_group" "default" {
  name       = var.db_subnet_group_name
  subnet_ids = var.subnet_ids

  tags = {
    Name = "My-DB-subnet-group"
  }
}
