
variable "region" {
    default = "eu-west-2"
    type        = string
}

variable "project_name" {
    type = string
}

variable "environment" {
    default = "dev"
    type = string
}

variable "vpc_cidr" {
     default = "10.0.0.0/16"
     type = string
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
  