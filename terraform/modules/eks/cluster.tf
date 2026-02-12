# ------------------------------------------------------------------------------
# EKS CONTROL PLANE (IMPLEMENTATION LAYER)
# ------------------------------------------------------------------------------

# This resource provisions the managed Kubernetes control plane.
#
# Architectural role:
# - Implements the control plane defined by root-level policy.
# - Does NOT contain environment logic.
# - Does NOT create IAM roles or networking.
#
# Dependencies:
# - VPC and private subnets (from Network module)
# - Cluster IAM role (from Security module)
#
# Design decisions:
# - Cluster runs in private subnets only.
# - API exposure is explicitly controlled via endpoint configuration.
# - Dedicated security group is attached to the control plane.
# - Tagging merges global platform tags with resource-specific Name.
#
# Non-responsibilities:
# - No node groups
# - No addons
# - No workload identity (IRSA handled separately)
# - No autoscaling configuration
#
# This separation ensures:
# - Clean layering (Network → Security → EKS)
# - Reusable module boundaries
# - Production-grade infrastructure design
#

resource "aws_eks_cluster" "this" {
  name     = var.cluster_name
  role_arn = var.cluster_role_arn
  version  = var.eks_version

  vpc_config {
    subnet_ids              = var.private_subnet_ids
    security_group_ids = [aws_security_group.cluster.id]
    endpoint_private_access = var.endpoint_private_access
    endpoint_public_access  = var.endpoint_public_access
  }

  tags = merge(
    var.tags,
    {
      Name = "${var.cluster_name}-eks"
    }
  )
}