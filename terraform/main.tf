# ------------------------------------------------------------------------------
# NETWORK MODULE
# ------------------------------------------------------------------------------

# This module defines the entire network layer (VPC, subnets, routing).
#
# Important architectural principle:
# - Root module decides "WHAT" environment we are in.
# - Network module only knows "HOW" to build infrastructure.
#

module "network" {
  source = "./modules/network"

  # VPC CIDR is environment-specific.
  # We select the correct CIDR block based on the current workspace.
  #
  # Example:
  # - dev  -> "10.0.0.0/16"
  # - prod -> "10.1.0.0/16"
  #

  vpc_cidr = var.vpc_cidr[local.env]

  # Public subnet CIDR blocks are also environment-specific.
  #
  # Example:
  # - dev  -> ["10.0.1.0/24"]
  # - prod -> ["10.1.1.0/24", "10.1.2.0/24"]
  #
  # The module does not know about environments.
  # It just receives a concrete list of CIDRs.
  #

  public_subnet_cidr = var.vpc_cidr_public_subnets_blocks[local.env]

  # Number of availability zones to use.
  #
  # Root module resolves the environment policy:
  # - dev  -> 1 AZ
  # - prod -> 2 AZs
  #
  # The network module receives only a number
  # and uses it to slice the AZ list.
  #

  az_count = var.az_count[local.env]

  # Pass unified tags into the module.
  # The module does not build tags itself.
  # This keeps tagging strategy centralized.
  #

  tags     = local.tags
}