variable "instance_name" {
  type = string
}

variable "ami_id" {
  type = string
}

variable "instance_type" {
  type = string
}

variable "security_groups" {
  type = list(any)
}

variable "subnet_id" {
}

variable "key_name" {
  type = string
}

variable "key_pair" {
  type = string
}

variable "user_data" {

}
