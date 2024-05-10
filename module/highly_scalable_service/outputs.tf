output "lb_dns_name" {
  value       = aws_lb.HelloSteve-LB.dns_name
  description = "DNS name of ALB."
}

output "azs" {
  value = data.aws_subnets.public_subnets.ids
}