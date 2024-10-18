variable "sg_name" {
  type        = string
  description = "Security group name"
}

variable "vpc_id" {
  type    = string
  default = "VPC id"
}

# variable "from_port" {
#   type        = number
#   description = "Port range"
# }

# variable "to_port" {
#   type        = number
#   description = "Port range"
# }

variable "cidr_block_sg" {
  type        = list(any)
  description = "List of cidr blocks"
}

variable "protocol" {
  type        = string
  description = "Protocol"
}

variable "ingress_ports" {
  type = set(number)
}

variable "security_groups" {
  type = list(any)
}

variable "egress_ports" {
  type = set(number)
}

variable "egress_protocol" {
  type = string
}
