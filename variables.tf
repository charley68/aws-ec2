
variable "region" {
    default = "eu-west-2"
    type        = string
}

variable "project_name" {
    default = "myProject"
    type        = string
}

variable "load_balancer_ingress" {
  type = list(object({
    protocol    = string
    from_port   = string
    to_port     = string
    cidr_blocks = list(string)
  }))
}

variable "private_subnets" {
    description = "List  of private subnets for the VPC"
    type = list(string)
}

variable "public_subnets" {
    description = "List  of public subnets for the VPC"
    type = list(string)
}

variable "azs" {
    description = "List  of azs"
    type = list(string)
}

variable "public_key_file" {
  default = "./mykey.pub"
}