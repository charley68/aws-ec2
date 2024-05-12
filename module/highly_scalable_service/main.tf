# Create 3 security groups. 
# 1) one for the load balancer which will allow HTTP traffic on port 80
# 2) one for the EC2 instance which will allow HTTP traffic from the LB SG only
# 3) one for EC2 allowing SSH for dev acccess
#

# Create an EC2. Add both SGs.
#
# Create a Target Group and Target Group Attatchment to register my EC2 with TG.
#
# Create a LOAD BALANCER and LOAD BALANACER LISTENER to fwd traffic to the TG.
#



# Create SG allowing HTTP traffic on port 80 for the LB


locals {
  tags = {
    Project = var.project_name
    Environment = var.environment
  }
}