
# Create SG allowing HTTP traffic on port 80 from LB only to prevent direct public access to the EC2
resource "aws_security_group" "HelloSteve-SG" {
 
  #vpc_id = var.vpc_id
  name = "${var.project_name}-SG"
  ingress {
    from_port   = var.ingress_port
    to_port     = var.ingress_port
    protocol    = "tcp"
    #security_groups = [aws_security_group.HelloSteveLB-SG.id]
    cidr_blocks = ["0.0.0.0/0"]
  }

  # needed this as couldnt do updates via nat without it
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = local.tags
}




# Create SG allowing SSH for dev access 
resource "aws_security_group" "HelloSteve-DEV-SG" {

  name = "${var.project_name}-DEV-SG"
  #vpc_id = var.vpc_id
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