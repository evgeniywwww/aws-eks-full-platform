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