# ------------------------------------------------------------------------------
# IAM ROLES: CREATING ROLES WITH TRUST POLICIES
# ------------------------------------------------------------------------------

# This resource creates IAM roles.
#
# for_each = var.iam_roles
# means:
# - One IAM role is created per entry in var.iam_roles
# - The map KEY becomes the role name
# - The map VALUE contains role configuration (principal, policies)
#
# Example:
# var.iam_roles = {
#   eks-cluster-role = { ... }
#   eks-node-role    = { ... }
# }
#
# Result:
# - aws_iam_role.this["eks-cluster-role"]
# - aws_iam_role.this["eks-node-role"]
#
# Each role has:
# - A unique name in AWS (name = each.key)
# - A trust policy (assume_role_policy)
#   that defines WHO is allowed to assume this role
#

resource "aws_iam_role" "this" {
  for_each = var.iam_roles
  name = each.key

  # Trust policy (AssumeRole policy).
  #
  # This policy answers the question:
  # "WHO is allowed to assume this role?"
  #
  # Example:
  # - eks.amazonaws.com  → EKS control plane
  # - ec2.amazonaws.com  → EC2 worker nodes
  #
  # This does NOT grant permissions yet.
  # It only defines who may wear this role.
  #

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = each.value.principal
        }
      },
    ]
  })

  tags = merge(
    var.tags,
    {
      Name = "iam-role-${each.key}"
    }
  )
}

# ------------------------------------------------------------------------------
# IAM ROLE POLICY ATTACHMENTS: BINDING POLICIES TO ROLES
# ------------------------------------------------------------------------------

# This resource attaches IAM policies to IAM roles.
#
# Important AWS/IAM rule:
# - A role can have MANY policies
# - BUT each attachment is always:
#     1 role ↔ 1 policy
#
# That is why we flattened role → policies
# into local.role_policy_map earlier.
#
# for_each = local.role_policy_map
# means:
# - One attachment per (role_name, policy_arn) pair
#
# Example keys:
# - "eks-cluster-role|AmazonEKSClusterPolicy"
# - "eks-node-role|AmazonEKSWorkerNodePolicy"
#
# each.value contains:
# - role_name
# - policy_arn
#

resource "aws_iam_role_policy_attachment" "this" {
  for_each = local.role_policy_map
  role       = each.value.role_name
  policy_arn = each.value.policy_arn
}