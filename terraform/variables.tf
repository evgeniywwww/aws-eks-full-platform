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
# NETWORK CONFIGURATION
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

# ------------------------------------------------------------------------------
# SECURITY CONFIGURATION
# ------------------------------------------------------------------------------

# IAM roles definition for the platform.
#
# This variable describes ALL IAM roles required by the platform
# and their security boundaries.
#
# Structure:
# - map key   → IAM role name (used as the actual AWS IAM Role name)
# - principal → AWS service allowed to initiate AssumeRole (trust policy)
# - policies  → List of AWS managed policy ARNs attached to the role
#
# Important clarification about `principal`:
#
# The value `eks.amazonaws.com` may appear in multiple roles.
# This does NOT mean that all these roles are used by the same component.
#
# In AWS IAM, the principal defines *which AWS service is allowed
# to initiate the AssumeRole call*, not the exact runtime identity.
#
# The actual identity assuming the role depends on the context:
# - EKS control plane (managed by AWS)
# - EC2 worker nodes
# - Kubernetes pods using IRSA (OIDC + ServiceAccount)
#
# Even if the principal is the same, roles are assumed in different
# contexts and represent different security boundaries.
#
# Design principles:
# - One role = one responsibility (identity)
# - Roles are defined declaratively in a single place
# - Policies are grouped per role, not duplicated
# - Least privilege is enforced by role separation
#
# Implementation notes:
# - Each policy in the list results in a separate policy attachment
# - Order of policies does NOT matter
# - Roles and role-policy relations are normalized in locals
#   before resource creation
#
# This structure is intentionally IRSA-ready and production-oriented.
#


variable "iam_roles" {
  description = "Map of IAM roles with principals and attached policies"
  type        = map(object({
    principal = string
    policies  = list(string)
  }))

  default = {
    eks-cluster-role = {
      principal = "eks.amazonaws.com"
      policies = [
        "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy",
        "arn:aws:iam::aws:policy/AmazonEKSVPCResourceController"
      ]
    }

    eks-node-role = {
      principal = "ec2.amazonaws.com"
      policies = [
        "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy",
        "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy",
        "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
      ]
    }

    eks-ebs-csi-role = {
      principal = "eks.amazonaws.com"
      policies = [
        "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
      ]
    }

    eks-lb-controller-role = {
      principal = "eks.amazonaws.com"
      policies = [
        "arn:aws:iam::aws:policy/AWSLoadBalancerControllerIAMPolicy"
      ]
    }

    eks-secrets-access-role = {
      principal = "eks.amazonaws.com"
      policies = [
        "arn:aws:iam::aws:policy/SecretsManagerReadWrite",
        "arn:aws:iam::aws:policy/AmazonSSMReadOnlyAccess"
      ]
    }

    eks-ai-data-role = {
      principal = "eks.amazonaws.com"
      policies = [
        "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess"
      ]
    }
  }
}

# ------------------------------------------------------------------------------
# EKS CONFIGURATION (CONTROL PLANE POLICY)
# ------------------------------------------------------------------------------

# This section defines environment-aware policy for the EKS control plane.
#
# Architectural principle:
# - Root module defines WHAT should be provisioned per environment.
# - EKS module defines HOW the control plane is created.
#
# These variables do not create infrastructure directly.
# They define environment-level intent (dev / prod),
# which is resolved in root using terraform.workspace
# and passed to the EKS module as concrete values.
#
# Design goals:
# - Environment isolation
# - Deterministic cluster naming
# - Explicit Kubernetes version management
# - Controlled API endpoint exposure
#
# All variables follow the pattern:
#   map(environment → value)
#
# This ensures:
# - No workspace logic inside modules
# - Centralized policy control
# - Predictable platform behavior
#

variable "cluster_name" {
  description = "EKS cluster name per environment"
  type        = map(string)

  default = {
    dev  = "platform-dev"
    prod = "platform-prod"
  }
}

variable "eks_version" {
  description = "EKS version per environment"
  type        = map(string)

  default = {
    dev  = "1.31"
    prod = "1.31"
  }
}

variable "eks_endpoint_private_access" {
  type        = map(bool)
  description = "Endpoint private access"

  default = {
    dev  = false
    prod = true
  }
}

variable "eks_endpoint_public_access" {
  type        = map(bool)
  description = "Endpoint public access"

  default = {
    dev  = true
    prod = false
  }
}