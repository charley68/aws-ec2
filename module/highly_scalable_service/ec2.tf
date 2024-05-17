

data "aws_availability_zones" "available" {
  state = "available"
}

# Create the EC2 instance
resource "aws_instance" "steve1" {

  #subnet_id = data.aws_subnets.public_subnets.ids[count.index]

  ami           = var.ami_id
  instance_type = var.instance_type
  iam_instance_profile = aws_iam_instance_profile.steve_profile.name
  vpc_security_group_ids = [aws_security_group.HelloSteve-SG.id, aws_security_group.HelloSteve-DEV-SG.id]

  associate_public_ip_address = true
  user_data = file(var.script_path)

  tags = local.tags
}