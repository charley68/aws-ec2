data "aws_availability_zones" "available" {}

locals {
  name            = var.project_name
  region          = var.region
  

  tags = {
    Project = var.project_name
    Terraform = "True"
    Environment = var.environment
  }
}


# Would would usually create seperate subnets for each project?
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "4.0.0"

  name = local.name

  cidr = var.vpc_cidr
  azs             = var.azs
  private_subnets =var.private_subnets
  public_subnets  = var.public_subnets

  public_subnet_tags = {Type = "Public"}
  private_subnet_tags = {Type = "Private"}

  enable_nat_gateway = true
  enable_vpn_gateway = true

  tags = local.tags
}
