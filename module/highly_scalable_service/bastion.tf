resource "aws_instance" "bastion" {

  subnet_id = data.aws_subnets.public_subnets.ids[0]

  ami           = var.ami_id
  instance_type = var.instance_type

  vpc_security_group_ids = [aws_security_group.Bastion-SG.id]
  associate_public_ip_address = true


  tags = merge(
    {Name = "Bastion"},
    local.tags
  )
}