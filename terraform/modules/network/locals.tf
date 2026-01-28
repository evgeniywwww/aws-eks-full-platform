# ------------------------------------------------------------------------------
# LOCALS: SELECTING AVAILABILITY ZONES
# ------------------------------------------------------------------------------

# Here we make the first architectural decision:
# how many availability zones we want to use.
#
# var.az_count is a NUMBER (for example: 1 for dev, 2 for prod).
#
# slice(...) takes the full list of AZs from AWS
# and selects only the first N zones.
#
# Result:
# - local.azs is a LIST of AZ names
# - Example for prod:
#   ["eu-west-1a", "eu-west-1b"]
#

locals {
  azs = slice(
    data.aws_availability_zones.available.names,
    0,
    var.az_count
  )
}

# This is the most important part.
#
# Goal:
# Build a MAP where:
# - key   = availability zone name
# - value = CIDR block for subnet in this AZ
#
# Input data:
# - local.azs                -> list of AZ names
# - var.public_subnet_cidr   -> list of CIDR blocks
#
# We iterate over AZs and:
# - use AZ name as the key
# - take CIDR with the same index from CIDR list
#
# Result example:
# {
#   "eu-west-1a" = "10.1.1.0/24"
#   "eu-west-1b" = "10.1.2.0/24"
# }
#
# This map fully describes how subnets should be created.
#

locals {
  public_subnets = {
    for idx, az in local.azs :
    az => var.public_subnet_cidr[idx]
  }

  private_subnets = {
    for idx, az in local.azs :
    az => var.private_subnet_cidr[idx]
  }
}