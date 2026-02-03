resource "aws_iam_role" "this" {
  for_each = var.iam_roles
  name = each.key

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

resource "aws_iam_role_policy_attachment" "this" {
  for_each = local.role_policy_map
  role       = each.value.role_name
  policy_arn = each.value.policy_arn
}