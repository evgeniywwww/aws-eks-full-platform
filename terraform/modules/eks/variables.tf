# ------------------------------------------------------------------------------
# EKS MODULE INPUT CONTRACT
# ------------------------------------------------------------------------------

# This section defines the input interface of the EKS module.
#
# Architectural principle:
# - Module receives resolved, environment-specific values from root.
# - Module contains NO workspace logic.
# - Module does NOT derive values internally.
#
# The EKS module consumes:
# - Identity (IAM role ARN)
# - Network context (VPC + private subnets)
# - Control plane policy (version + endpoint exposure)
# - Global tagging strategy
#
# All inputs are concrete values.
# No map(env → value) logic exists inside this module.
#
# This keeps the module:
# - Reusable
# - Deterministic
# - Environment-agnostic
# ------------------------------------------------------------------------------


variable "cluster_name" {
  type = string
}

variable "eks_version" {
  type = string
}

variable "private_subnet_ids" {
  type = list(string)
}

variable "vpc_id" {
  type = string
}

variable "cluster_role_arn" {
  type = string
}

variable "endpoint_public_access" {
  type = bool
}

variable "endpoint_private_access" {
  type = bool
}

variable "tags" {
  type = map(string)
}
