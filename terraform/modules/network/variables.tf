variable "vpc_cidr" {
  type = string
}

variable "tags" {
  type = map(string)
}

variable "public_subnet_cidr" {
  type        = string
  description = "CIDR block for public subnet"
}

variable "private_subnet_cidr" {
  type        = string
  description = "CIDR block for private subnet"
}