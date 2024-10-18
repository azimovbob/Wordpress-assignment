resource "aws_instance" "default" {
  ami             = var.ami_id
  instance_type   = var.instance_type
  security_groups = var.security_groups
  subnet_id       = var.subnet_id
  key_name        = aws_key_pair.tf_key.key_name
  user_data       = var.user_data
  tags = {
    Name = var.instance_name
  }

  depends_on = [aws_key_pair.tf_key]


}

resource "aws_key_pair" "tf_key" {
  key_name   = var.key_name
  public_key = var.key_pair
}
