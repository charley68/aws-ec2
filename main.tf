
# I found this quite tough.  Adding my own VPC seemed to create problems 
# i got a bit lost around subnets and azs.
# not sure if im meant to create multiple instances of the ec2 (1 in each subnet for each AZ?)
# And do i have just One LB that spans all AZs

module "steve_vpc" {
  source = "./module/vpc"
  project_name = var.project_name
  region = var.region
  public_subnets = var.public_subnets
  private_subnets = var.private_subnets
  azs = var.azs
}

module "scaleable" {

  depends_on = [ module.steve_vpc ]
  # can also include githiub link here
  source = "./module/highly_scalable_service"
  script_path = "./script.sh"
  load_balancer_ingress = var.load_balancer_ingress
  vpc_id = module.steve_vpc.vpc_id
  project_name = var.project_name
}