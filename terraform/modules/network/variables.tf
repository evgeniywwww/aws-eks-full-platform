# ------------------------------------------------------------------------------
# INPUT VARIABLES
# ------------------------------------------------------------------------------

# CIDR block for the VPC itself

variable "vpc_cidr" {
  type = string
}

# Common tags applied to all resources
# Example: Project, Environment, ManagedBy

variable "tags" {
  type = map(string)
}

# List of CIDR blocks for public subnets.
#
# The order of this list MUST match the order of availability zones.
#
# Example:
# ["10.1.1.0/24", "10.1.2.0/24"]
#

variable "public_subnet_cidr" {
  type        = list(string)
  description = "CIDR block for public subnet"
}

# Number of availability zones to use.
#
# This value is already resolved in the root module
# (for example: dev=1, prod=2).
#
# The network module does not know about environments,
# it just receives a concrete number.
#

variable "az_count" {
  type        = number
  description = "Number of AZs to use"
}