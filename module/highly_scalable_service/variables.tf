
variable "region" {
    default = "eu-west-2"
    type        = string
}

variable "cluster_name" {
    default = "demo-cluster"
    type        = string
}

variable "ingress_port" {
  default = "80"
  type = string
}

variable "allowed_cidrs" {
  default = ["0.0.0.0/0"]
  type = list(string)
}

variable "ami_id" {
    default = "ami-008ea0202116dbc56"
    type = string
}

variable "instance_type" {
   default = "t2.micro"
   type = string
}

variable "script_path" {
  type = string
}

variable "loadbalancer_type" {
    default = "application"
    type = string
}