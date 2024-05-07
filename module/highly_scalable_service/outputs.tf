output "lb_dns_name" {
  value       = aws_lb.HelloSteve-LB.dns_name
  description = "DNS name of ALB."
}

output "steve" {
  value = data.aws_subnets.public_subnets.ids
}

output "azs" {
  value = data.aws_availability_zones.available
}