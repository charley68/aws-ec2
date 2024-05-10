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

resource "aws_security_group" "HelloSteveLB-SG" {
 
  vpc_id = var.vpc_id
  name = "${var.project_name}-LB-SG"

    # Should i be using dyynamic here or  aws_security_group_rule ??
    dynamic "ingress" {
        for_each = var.load_balancer_ingress
        iterator = ingressRule

        content {
            from_port   = ingressRule.value["from_port"]
            to_port     = ingressRule.value["to_port"]
            protocol    = ingressRule.value["protocol"]
            cidr_blocks = ingressRule.value["cidr_blocks"]
        }
    }   
  
      dynamic "egress" {
        for_each = var.load_balancer_egress
        iterator = egressRule

        content {
            from_port   = egressRule.value["from_port"]
            to_port     = egressRule.value["to_port"]
            protocol    = egressRule.value["protocol"]
            cidr_blocks = egressRule.value["cidr_blocks"]
        }
      }
}


# Create SG allowing HTTP traffic on port 80 from LB only to prevent direct public access to the EC2
resource "aws_security_group" "HelloSteve-SG" {
 
  vpc_id = var.vpc_id
  name = "${var.project_name}-SG"
  ingress {
    from_port   = var.ingress_port
    to_port     = var.ingress_port
    protocol    = "tcp"
    security_groups = [aws_security_group.HelloSteveLB-SG.id]
  }
}

# Create SG allowing SSH for dev access 
resource "aws_security_group" "HelloSteve-DEV-SG" {

  name = "${var.project_name}-DEV-SG"
  vpc_id = var.vpc_id


 /* ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }*/
}

# This is another way to add muiltiple SG rules instad of using dnyamic.  Here we can specify ingress or egress
# as well 
resource "aws_security_group_rule" "dev_sec_rules" {
  count = length(var.dev_security_rules)
  type = var.dev_security_rules[count.index].type
  from_port         = var.dev_security_rules[count.index].from_port
  to_port           = var.dev_security_rules[count.index].to_port
  protocol          = var.dev_security_rules[count.index].protocol
  cidr_blocks       = [var.dev_security_rules[count.index].cidr_block]
  description       = var.dev_security_rules[count.index].description
  security_group_id = aws_security_group.HelloSteve-DEV-SG.id
}
/*
# Create the EC2 instance
resource "aws_instance" "steve1" {

  # Seems to be two ways to create mutliple resournces
  # 1) using  count and count.index
  # 2) using for_each and each.value

  # The "count" value depends on resource attributes that cannot be determined until # apply, so Terraform cannot predict how many instances will be created. To work around # this, use the  -target argument to first apply only the resources that the count 
  # depends on.
  count = length(data.aws_availability_zones.available.names)
  subnet_id = data.aws_subnets.public_subnets.ids[count.index]

  ami           = var.ami_id
  instance_type = var.instance_type

  vpc_security_group_ids = [aws_security_group.HelloSteve-SG.id, aws_security_group.HelloSteve-DEV-SG.id]

  associate_public_ip_address = true
  user_data = file(var.script_path)

  tags = local.tags
}*/


# For ASG, we dont specify the aws_instance but instead specify a aws_launch_configutation
resource "aws_launch_configuration" "steve1" {

  name_prefix     = "terraform-aws-asg-"
  image_id        = var.ami_id
  instance_type   = var.instance_type
  user_data       = file(var.script_path)
  security_groups = [aws_security_group.HelloSteve-SG.id, aws_security_group.HelloSteve-DEV-SG.id]

  lifecycle {
    create_before_destroy = true
  }
}

/*
module.scaleable.aws_autoscaling_group.steve1: Creating...
╷
│ Error: waiting for Auto Scaling Group (terraform-20240510101202455000000001) capacity satisfied: scaling activity (06563d87-f45b-15ce-67ad-4047db01a4d7): Failed: Security group sg-0beda05df5d661343 and subnet subnet-08df3395fd6ed277c belong to different networks. Launching EC2 instance failed.
│ 
│   with module.scaleable.aws_autoscaling_group.steve1,
│   on module/highly_scalable_service/main.tf line 152, in resource "aws_autoscaling_group" "steve1":
│  152: resource "aws_autoscaling_group" "steve1" {

  */
resource "aws_autoscaling_group" "steve1" {
  min_size             = 1
  max_size             = 3
  desired_capacity     = 1
  launch_configuration = aws_launch_configuration.steve1.name
  availability_zones  = var.azs
}


# Create a TargetGroup
resource "aws_lb_target_group" "HelloSteve-TG" {
  name = "${var.project_name}-TG"
  port     = 80
  protocol = "HTTP"
  vpc_id = var.vpc_id 

}


# For ASG, we create an aws_autoscaling_attachment.  For EC2 instances, we create aws_lb_target_attachment since we know the EC2s in this case.
resource "aws_autoscaling_attachment" "steve1" {
  autoscaling_group_name = aws_autoscaling_group.steve1.id
  lb_target_group_arn   = aws_lb_target_group.HelloSteve-TG.arn
}

/*
# Register our EC2 instance's with the Target Group
resource "aws_lb_target_group_attachment" "HelloSteveTG-reg" {

  depends_on = [ aws_instance.steve1 ]
  target_group_arn = aws_lb_target_group.HelloSteve-TG.arn



    # I understand this but how do i find out what key/values are returned by aws_isntance.steve1? 
    # i couldnt work out how to debug this to see how it works as cant reference module resources from tf console
    for_each = {
       for k, v in aws_instance.steve1 : k => v
  }

  target_id        = each.value.id
}

data "aws_availability_zones" "available" {
  state = "available"
}*/

data "aws_subnets" "public_subnets" {
  filter {
    name   = "vpc-id"
    values = [var.vpc_id]
  }

  tags = {
    Type = "Public"
  }
}


# Create Load Balancer
resource "aws_lb" "HelloSteve-LB" {
  name = "${var.project_name}-LB"
  internal           = false
  load_balancer_type = var.loadbalancer_type
  security_groups    = [aws_security_group.HelloSteveLB-SG.id]

  subnets            = data.aws_subnets.public_subnets.ids
 
  tags = local.tags
}

# We want to foward traffic from HTTP/80 to our TG
resource "aws_lb_listener" "HelloSteve-LB-Listener" {
  load_balancer_arn = aws_lb.HelloSteve-LB.arn
  port              = var.loadbalancer_listener_port
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.HelloSteve-TG.arn
  }

  tags = local.tags
}