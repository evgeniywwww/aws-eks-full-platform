variable "project_name" {
  type = string
}

variable "aws_region" {
  type = string
}

variable "owner" {
  type        = string
  description = "Owner of the infrastructure"
  default     = "Administrator"
}

variable "common_tags" {
  type        = map(string)
  description = "Common tags applied to all resources"
  default     = {}
}


variable "vpc_cidr" {
  type        = map(string)
  description = "VPC CIDR per environment"

  default = {
    dev  = "10.0.0.0/16"
    prod = "10.1.0.0/16"
  }
}

variable "vpc_cidr_public_subnets_blocks" {
  type        = map(string)
  description = "VPC CIDR Blocks Public per environment"

  default = {
    dev  = "10.0.1.0/24"
    prod = "10.1.1.0/24"
  }
}

variable "vpc_cidr_private_subnets_blocks" {
  type        = map(string)
  description = "VPC CIDR Blocks Private per environment"

  default = {
    dev  = "10.0.2.0/24"
    prod = "10.1.2.0/24"
  }
}