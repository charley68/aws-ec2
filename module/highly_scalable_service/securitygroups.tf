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