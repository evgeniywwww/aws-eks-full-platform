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