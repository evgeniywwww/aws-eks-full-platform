locals {
  env = terraform.workspace

  tags = merge(
    var.common_tags,
    {
      Project     = var.project_name
      Environment = local.env
    }
  )
}
