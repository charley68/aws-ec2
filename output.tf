

# Looks like module outputs are consumed and need to be duplicated in the root to display them.
output "lb_name" {
    value = "${module.scaleable.lb_dns_name}"
}

output "azs" {
    value = module.scaleable.azs
}