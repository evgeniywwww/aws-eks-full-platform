# ------------------------------------------------------------------------------
# ROOT INPUT VARIABLES
# ------------------------------------------------------------------------------

# Name of the project.
# Used in tags and resource naming.
#

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

# Common tags applied to all resources.
#
# These tags are environment-agnostic.
# Example:
# {
#   Owner       = "PlatformTeam"
#   CostCenter  = "AI-Platform"
# }
#

variable "common_tags" {
  type        = map(string)
  description = "Common tags applied to all resources"
  default     = {}
}

# ------------------------------------------------------------------------------
# ENVIRONMENT-SPECIFIC CONFIGURATION
# ------------------------------------------------------------------------------

# VPC CIDR blocks per environment.
#
# Root module defines environment policy.
# Modules consume resolved values.
#

variable "vpc_cidr" {
  type        = map(string)
  description = "VPC CIDR per environment"

  default = {
    dev  = "10.0.0.0/16"
    prod = "10.1.0.0/16"
  }
}

# Subnets CIDR blocks per environment.
#
# Order matters:
# - CIDR blocks must align with availability zones.
#

variable "vpc_cidr_public_subnets_blocks" {
  type        = map(list(string))
  description = "VPC CIDR Blocks Public per environment"

  default = {
    dev  = ["10.0.1.0/24"]
    prod = ["10.1.1.0/24", "10.1.2.0/24"]
  }
}

variable "vpc_cidr_private_subnets_blocks" {
  type        = map(list(string))
  description = "VPC CIDR Blocks Private per environment"

  default = {
    dev  = ["10.10.1.0/24"]
    prod = ["10.11.1.0/24", "10.11.2.0/24"]
  }
}

# Number of availability zones per environment.
#
# This value controls:
# - how many AZs are selected
# - how many subnets are created
#

variable "az_count" {
  type        = map(number)
  description = "Number of AZs per environment"

  default = {
    dev  = 1
    prod = 2
  }
}