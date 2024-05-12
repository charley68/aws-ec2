data "aws_subnets" "public_subnets" {
  filter {
    name   = "vpc-id"
    values = [var.vpc_id]
  }

  tags = {
    Type = "Public"
  }
}

# Create a TargetGroup
resource "aws_lb_target_group" "HelloSteve-TG" {
  name = "${var.project_name}-TG"
  port     = 80
  protocol = "HTTP"
  vpc_id = var.vpc_id 

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

/*
# Register our EC2 instance's with the Target Group
# Dont need this whenusing ASGs as ASG will register the TG

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

