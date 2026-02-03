locals {
  role_policy_map = {
    for role_name, role in var.iam_roles :
      for policy_arn in role.policies
        "${role_name}|${policy_arn}" => {
          role_name  = role_name
          policy_arn = policy_arn
    }
  }
}