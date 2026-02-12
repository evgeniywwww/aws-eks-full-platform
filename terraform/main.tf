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

  # Subnets CIDR blocks are also environment-specific.
  #
  # Example:
  # - dev  -> ["10.0.1.0/24"]
  # - prod -> ["10.1.1.0/24", "10.1.2.0/24"]
  #
  # The module does not know about environments.
  # It just receives a concrete list of CIDRs.
  #

  public_subnet_cidr = var.vpc_cidr_public_subnets_blocks[local.env]
  private_subnet_cidr = var.vpc_cidr_private_subnets_blocks[local.env]

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

# ------------------------------------------------------------------------------
# SECURITY MODULE
# ------------------------------------------------------------------------------

# This module defines the entire IAM layer of the platform.
#
# Architectural principle:
# - Root module defines "WHAT identities exist" via declarative iam_roles.
# - Security module defines "HOW identities are created and attached to policies".
#
# Responsibilities:
# - Create IAM roles
# - Define trust relationships (who can assume the role)
# - Attach managed policies
#
# Non-Responsibilities:
# - No knowledge of EKS, EC2, or workloads
# - No environment logic (dev/prod)
# - No hardcoded AWS services
#
# Output contract:
# - role_arns (map(role_name => arn))
#
# This allows other modules (e.g. EKS) to consume identities
# without coupling to IAM implementation details.
#

module "security" {
  source = "./modules/security"
  iam_roles = var.iam_roles
  tags   = local.tags
}

# ------------------------------------------------------------------------------
# EKS MODULE (CONTROL PLANE LAYER)
# ------------------------------------------------------------------------------

# This module defines the Kubernetes control plane layer of the platform.
#
# Architectural principles:
#
# - Root module decides "WHAT" environment we are in (dev / prod).
# - Root module defines policy (cluster name, version, endpoint exposure).
# - EKS module only defines "HOW" to provision the control plane.
#
# Responsibilities:
# - Create the EKS control plane
# - Bind cluster to private subnets
# - Attach the pre-defined IAM cluster role
# - Configure API endpoint exposure (public/private)
# - Associate a dedicated cluster security group
#
# Non-Responsibilities:
# - Does NOT create node groups
# - Does NOT define IAM roles
# - Does NOT manage addons
# - Does NOT implement autoscaling
# - Does NOT contain environment logic
#
# Dependency model:
# - Consumes VPC and subnet outputs from the Network module
# - Consumes IAM role ARNs from the Security module
#
# Output contract:
# - cluster_name
# - cluster_endpoint
# - cluster_ca_data
# - cluster_oidc_issuer
#
# This strict separation ensures:
# - Clear module boundaries
# - Reusable infrastructure components
# - Production-grade layering
#

module "eks" {
  source = "./modules/eks"

  cluster_name = var.cluster_name[local.env]
  eks_version      = var.eks_version[local.env]

  vpc_id             = module.network.vpc_id
  private_subnet_ids = module.network.private_subnet_ids

  cluster_role_arn = module.security.role_arns["eks-cluster-role"]

  endpoint_private_access = var.eks_endpoint_private_access[local.env]
  endpoint_public_access  = var.eks_endpoint_public_access[local.env]

  tags = local.tags
}