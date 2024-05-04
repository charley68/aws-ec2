module "scaleable" {

  # can also include githiub link here
  source = "./module/highly_scalable_service"
  script_path = "./script.sh"
  ingress_port = var.ingress_port
  load_balancer_ingress = var.load_balancer_ingress
}
