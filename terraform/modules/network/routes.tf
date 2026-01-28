# Internet Gateway is the entry/exit point between the VPC and the public internet.
#
# Architectural role:
# - Provides direct internet connectivity for public subnets
# - Does NOT perform NAT or IP translation
# - Required for:
#   - public subnets
#   - NAT Gateways
#   - Load Balancers (ALB/NLB)
#
# There is exactly ONE Internet Gateway per VPC.
#

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id

  tags = merge(
    var.tags,
    {
      Name = "public-igw"
    }
  )
}

# This route table defines how PUBLIC subnets reach the internet.
#
# Architectural role:
# - Any subnet associated with this route table becomes a public subnet
# - Traffic destined to the internet (0.0.0.0/0) is routed directly
#   to the Internet Gateway
#
# Important:
# - No NAT is used here
# - Instances in public subnets must have public IPs
#

resource "aws_route_table" "public_routing_table" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }

  tags = merge(
    var.tags,
    {
      Name = "public-rt"
    }
  )
}

# Private route tables control outbound traffic from private subnets.
#
# Architectural role:
# - Private subnets do NOT have direct internet access
# - All outbound traffic is routed through a NAT Gateway
#
# Why for_each:
# - Each Availability Zone has its own NAT Gateway
# - Each private subnet must use the NAT Gateway in the SAME AZ
# - This ensures fault isolation and avoids cross-AZ traffic
#
resource "aws_route_table" "private_routing_table" {
  vpc_id = aws_vpc.main.id

  for_each = aws_subnet.private
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.nat_gw[each.key].id
  }

  tags = merge(
    var.tags,
    {
      Name = "private-rt-${each.key}"
    }
  )
}

# Elastic IPs provide stable public IPv4 addresses.
#
# Architectural role:
# - Used by NAT Gateways to provide controlled outbound internet access
# - Ensures that traffic from private subnets always originates
#   from known, static public IPs
#
# Why for_each:
# - NAT Gateways are zonal resources
# - Each NAT Gateway requires its own Elastic IP
#

resource "aws_eip" "nat_eip" {
  for_each = aws_subnet.public
  tags = merge(
    var.tags,
    {
      Name = "nat-eip-${each.key}"
    }
  )
}

# NAT Gateways enable outbound internet access for private subnets.
#
# Architectural role:
# - Perform source NAT (IP translation) for private IP addresses
# - Allow private subnets to reach the internet
# - Do NOT allow inbound connections
#
# Why for_each is used here:
# - NAT Gateways are zonal resources (one per Availability Zone)
# - Each private subnet must use a NAT Gateway in the SAME AZ
# - Therefore, we create one NAT Gateway per public subnet (per AZ)
#
# How for_each works in this resource:
# - aws_subnet.public is a MAP of public subnets keyed by AZ name
#   Example:
#   {
#     "eu-west-1a" = <public subnet in eu-west-1a>
#     "eu-west-1b" = <public subnet in eu-west-1b>
#   }
#
# - each.key   = Availability Zone name (e.g. "eu-west-1a")
# - each.value = Public subnet object for that AZ
#
# Resource linking logic:
# - subnet_id     → places the NAT Gateway inside the public subnet of the same AZ
# - allocation_id → attaches the Elastic IP created for the same AZ
#
# Result:
# - One NAT Gateway per Availability Zone
# - Each NAT Gateway has its own Elastic IP
# - Private subnets route traffic to the NAT Gateway in their AZ
#

resource "aws_nat_gateway" "nat_gw" {
  for_each = aws_subnet.public
  allocation_id = aws_eip.nat_eip[each.key].id
  subnet_id     = each.value.id

  tags = merge(
    var.tags,
    {
      Name = "nat-gw-${each.key}"
    }
  )

  # To ensure proper ordering, it is recommended to add an explicit dependency
  # on the Internet Gateway for the VPC.
  depends_on = [aws_internet_gateway.gw]
}