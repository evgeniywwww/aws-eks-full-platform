# ==============================================================================
# OUTPUTS (outputs.tf)
# ==============================================================================
#
# This file exposes the key networking artifacts created by the network module.
#
# Outputs are intentionally minimal and explicit:
# - Only values that are required by higher-level modules (EKS, ALB, etc.)
# - No internal implementation details
#
# These outputs are used as inputs for:
# - EKS control plane
# - Node groups
# - Load balancers
# - Security groups
#
# ==============================================================================

output "vpc_id" {
  description = "VPC ID"
  value       = aws_vpc.main.id
}

output "public_subnet_ids" {
  description = "List of public subnet IDs"
  value       = values(aws_subnet.public)[*].id
}

output "private_subnet_ids" {
  description = "List of private subnet IDs"
  value       = values(aws_subnet.private)[*].id
}

output "nat_gateway_ids" {
  description = "List of NAT Gateway IDs"
  value       = values(aws_nat_gateway.nat_gw)[*].id
}

output "availability_zones" {
  description = "Availability Zones used by the network"
  value       = local.azs
}

output "nat_eip_public_ips_by_az" {
  description = "Elastic IPs for NAT Gateways mapped by Availability Zone"
  value = {
    for az, eip in aws_eip.nat_eip :
    az => eip.public_ip
  }
}