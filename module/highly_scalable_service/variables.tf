
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

variable "load_balancer_ingress" {
  type = list(object({
    protocol    = string
    from_port   = string
    to_port     = string
    cidr_blocks = list(string)
  }))
  default = [{ protocol="tcp", 
              from_port = 80, 
              to_port=80, 
              cidr_blocks = ["0.0.0.0/0"]}]
}

variable "load_balancer_egress" {
  type = list(object({
    protocol    = string
    from_port   = string
    to_port     = string
    cidr_blocks = list(string)
  }))
  default = [{ protocol="-1", 
              from_port = 0, 
              to_port=0, 
              cidr_blocks = ["0.0.0.0/0"]}]
}