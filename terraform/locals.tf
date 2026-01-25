# ------------------------------------------------------------------------------
# LOCALS: ENVIRONMENT AND TAG STRATEGY
# ------------------------------------------------------------------------------

# terraform.workspace defines the current environment.
# Typical values: "dev", "prod", "staging".
#
# This value is used as a key to select environment-specific configuration.
#

locals {
  env = terraform.workspace

  # Here we build a unified tags map that will be applied to all resources.
  #
  # Strategy:
  # - common_tags come from variables (shared across environments)
  # - project_name is a required identifier
  # - environment tag is derived from the current workspace
  #
  # This allows:
  # - consistent tagging
  # - cost tracking
  # - environment isolation
  #


  tags = merge(
    var.common_tags,
    {
      Project     = var.project_name
      Environment = local.env
    }
  )
}
