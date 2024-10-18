variable "subnet_name" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "cidr_subnet" {
  type = string
}

variable "az" {
  type = string
}

variable "assign_public_ip" {
  type    = bool
  default = false
}
