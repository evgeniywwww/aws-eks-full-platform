# ------------------------------------------------------------------------------
# LOCALS: FLATTENING ROLE → POLICY RELATIONSHIPS
# ------------------------------------------------------------------------------

# At this stage we solve a fundamental Terraform limitation:
#
# - aws_iam_role_policy_attachment supports ONLY:
#     1 role  ↔  1 policy
#
# - But our input model is:
#     1 role  ↔  MANY policies
#
# Therefore, we must transform:
#   map(role_name -> list(policy_arn))
#
# Into a flat collection where each element represents:
#   { role_name, policy_arn }
#
# This is a purely structural transformation.
# No AWS resources are created here.
#

locals {
  # Step 1:
  # Build a LIST of LISTS of objects:
  #
  # For each role:
  #   - iterate over its policies
  #   - create an object:
  #       {
  #         role_name  = "<role name>"
  #         policy_arn = "<policy arn>"
  #       }
  #
  # Result BEFORE flatten:
  # [
  #   [
  #     { role_name = "eks-cluster-role", policy_arn = "policy-1" },
  #     { role_name = "eks-cluster-role", policy_arn = "policy-2" }
  #   ],
  #   [
  #     { role_name = "eks-node-role", policy_arn = "policy-3" },
  #     { role_name = "eks-node-role", policy_arn = "policy-4" }
  #   ]
  # ]
  #
  # flatten(...) removes one nesting level and produces:
  # [
  #   { role_name = "...", policy_arn = "..." },
  #   { role_name = "...", policy_arn = "..." },
  #   ...
  # ]

  role_policy_pairs = flatten ([
    for role_name, role in var.iam_roles : [
      for policy_arn in role.policies : {
          role_name  = role_name
          policy_arn = policy_arn
    }
    ]
  ])
}

# ------------------------------------------------------------------------------
# LOCALS: CONVERTING LIST TO MAP FOR for_each
# ------------------------------------------------------------------------------

# Terraform for_each requires:
# - a MAP or a SET
# - with UNIQUE KEYS
#
# role_policy_pairs is a LIST, so we convert it to a MAP.
#
# We generate a UNIQUE key by combining:
#   "<role_name>|<policy_arn>"
#
# This guarantees:
# - No collisions
# - Stable Terraform addresses
# - Clear mapping in the state file
#
# Final structure:
# {
#   "eks-cluster-role|policy-1" = {
#     role_name  = "eks-cluster-role"
#     policy_arn = "policy-1"
#   }
#   "eks-node-role|policy-3" = {
#     role_name  = "eks-node-role"
#     policy_arn = "policy-3"
#   }
# }

locals {
  role_policy_map = {
    for pair in local.role_policy_pairs :
    "${pair.role_name}|${pair.policy_arn}" => pair
  }
}
