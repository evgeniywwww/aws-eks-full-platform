# ------------------------------------------------------------------------------
# EKS CLUSTER SECURITY GROUP (NETWORK BOUNDARY)
# ------------------------------------------------------------------------------

# This security group defines the network boundary for the EKS control plane.
#
# Architectural role:
# - Provides an additional isolation layer for the control plane ENIs.
# - Attached explicitly via vpc_config in aws_eks_cluster.
#
# Design principles:
# - Dedicated security group per cluster.
# - No implicit reuse of shared or "default" security groups.
# - Explicit egress definition for clarity and auditability.
#
# Important notes:
# - Ingress to the Kubernetes API is controlled via:
#     endpoint_private_access
#     endpoint_public_access
#   NOT via standard ingress rules.
#
# - AWS also creates a managed cluster security group internally.
#   This resource defines an additional, explicit boundary.
#
# - Egress is intentionally open (0.0.0.0/0),
#   allowing the control plane to communicate with AWS services.
#
# Non-responsibilities:
# - Does NOT define node-to-node traffic.
# - Does NOT define workload ingress.
# - Does NOT manage load balancer exposure.
#
# This separation keeps:
# - Control plane networking isolated
# - Compute layer independent
# - Runtime networking extensible
#

resource "aws_security_group" "cluster" {
  name        = "${var.cluster_name}-cluster-sg"
  description = "EKS control plane security group"
  vpc_id      = var.vpc_id

  tags = merge(
    var.tags,
    {
      Name = "${var.cluster_name}-cluster-sg"
    }
  )
}

resource "aws_security_group_rule" "cluster_egress" {
  type              = "egress"
  security_group_id = aws_security_group.cluster.id

  from_port   = 0
  to_port     = 0
  protocol    = "-1"
  cidr_blocks = ["0.0.0.0/0"]
}