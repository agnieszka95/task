provider "aws" {
  region = "eu-north-1"
}

module "vpc" {
  source  = "../../modules/vpc"

  vpc_cidr_block = var.vpc_cidr_block
  public_subnet_cidrs = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
}

module "nat" {
  source  = "../../modules/nat"
  subnet_id = module.vpc.public_subnet_ids[0]
}

module "eks" {
  source  = "../../modules/eks"

  cluster_name    = var.cluster_name
  vpc_id          = module.vpc.vpc_id
  private_subnet_ids = module.vpc.private_subnet_ids

}
