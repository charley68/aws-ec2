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


# REPLACE BELOW WITH VPC MODULE
resource "aws_default_vpc" "default" {
  tags = {
    Name = "Default VPC"
  }
}


# Create SG allowing HTTP traffic on port 80 for the LB
resource "aws_security_group" "HelloSteveLB-SG" {
 
  name = "HelloSteveLB-SG"

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
 
  name = "HelloSteve-SG"
  ingress {
    from_port   = var.ingress_port
    to_port     = var.ingress_port
    protocol    = "tcp"
    security_groups = [aws_security_group.HelloSteveLB-SG.id]
  }
}

# Create SG allowing SSH for dev access 
resource "aws_security_group" "HelloSteve-DEV-SG" {

  name = "HelloSteve-DEV-SG"
  ingress {
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

  # needed this initially so we can access internet to run the apache install.  I guess maybe this would usually be in a private subnet and use NAT Gateway ?
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}


# Create the EC2 instance
resource "aws_instance" "steve1" {
  ami           = var.ami_id
  instance_type = var.instance_type


  # Despite the hashicrap documentation saying security_groups is ok for default VPC, i had to use vpc_security_group_ids
  #security_groups = [aws_security_group.HelloSteve-SG.id, aws_security_group.HelloSteve-DEV-SG.id]
  vpc_security_group_ids = [aws_security_group.HelloSteve-SG.id, aws_security_group.HelloSteve-DEV-SG.id]

  user_data = file(var.script_path)

  tags = {
    Name = "HelloSteve"
  }
}

# Create a TargetGroup
resource "aws_lb_target_group" "HelloSteve-TG" {
  name     = "HelloSteve-TG"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_default_vpc.default.id
}

# Register our EC2 instance with the Target Group
resource "aws_lb_target_group_attachment" "HelloSteveTG-reg" {

  depends_on = [ aws_instance.steve1 ]
  target_group_arn = aws_lb_target_group.HelloSteve-TG.arn
  target_id        = aws_instance.steve1.id
}

# I struggled with this - getting the subnets for my default VPC
data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [aws_default_vpc.default.id]
  }
}

# Create Load Balancer
resource "aws_lb" "HelloSteve-LB" {
  name               = "hello-steve-lb"
  internal           = false
  load_balancer_type = var.loadbalancer_type
  security_groups    = [aws_security_group.HelloSteveLB-SG.id]


  # Docs say this is optional but without it, it complains "ONE OF SUBNET_MAPPING, SUBNETS MUST BE SPECIFIED"
  subnets            = data.aws_subnets.default.ids

  #enable_deletion_protection = true

  #access_logs {
  #  bucket  = aws_s3_bucket.lb_logs.id
  #  prefix  = "test-lb"
  #  enabled = true
  #}

  tags = {
    Environment = "Steve1"
  }
}

# We want to foward traffic from HTTP/80 to our TG
resource "aws_lb_listener" "HelloSteve-LB-Listener" {
  load_balancer_arn = aws_lb.HelloSteve-LB.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.HelloSteve-TG.arn
  }

  tags = {
    Environment = "Steve1"
  }
}
