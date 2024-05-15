

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

resource "aws_key_pair" "TFkeypair" {
  key_name   = "TFmykeypair"
  public_key = file(var.public_key_file)
}

# For ASG, we dont specify the aws_instance but instead specify a aws_launch_configutation
resource "aws_launch_configuration" "steve1" {

  name_prefix     = "terraform-aws-asg-"
  image_id        = var.ami_id
  instance_type   = var.instance_type
  user_data       = file(var.script_path)
  iam_instance_profile = aws_iam_instance_profile.steve_profile.name
  security_groups = [aws_security_group.HelloSteve-SG.id, aws_security_group.Bastion-connect-SG.id]
  #associate_public_ip_address = true
  key_name = aws_key_pair.TFkeypair.key_name

  # Whats the reason for this ??
  lifecycle {
    create_before_destroy = true
  }
}