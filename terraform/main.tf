module "network" {
  source = "./modules/network"

  vpc_cidr = var.vpc_cidr[local.env]
  public_subnet_cidr = var.vpc_cidr_public_subnets_blocks[local.env]
  private_subnet_cidr = var.vpc_cidr_private_subnets_blocks[local.env]
  tags     = local.tags
}