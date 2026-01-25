# ------------------------------------------------------------------------------
# RESOURCE: PUBLIC SUBNETS
# ------------------------------------------------------------------------------

# This resource uses the subnet map created in locals.
#
# for_each iterates over the map:
# - each.key   -> availability zone
# - each.value -> CIDR block
#
# Terraform will create ONE subnet per map entry.
#
# Example results:
# - aws_subnet.public["eu-west-1a"]
# - aws_subnet.public["eu-west-1b"]
#

resource "aws_subnet" "public" {
  for_each = local.public_subnets
  vpc_id     = aws_vpc.main.id
  availability_zone = each.key
  cidr_block = each.value

  tags = var.tags
}