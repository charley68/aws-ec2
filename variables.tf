
variable "region" {
    default = "eu-west-2"
    type        = string
}

variable "cluster_name" {
    default = "demo-cluster"
    type        = string
}

variable "ingress_port" {
}

variable "load_balancer_ingress" {
  type = list(object({
    protocol    = string
    from_port   = string
    to_port     = string
    cidr_blocks = list(string)
  }))
}