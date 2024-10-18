variable "cidr_rt" {
  type        = string
  description = "CIDR block for Route table"
}

variable "vpc_id" {
  type = string
}

variable "rt_name" {
  type = string
}

variable "nat_id" {
  type = string
}
