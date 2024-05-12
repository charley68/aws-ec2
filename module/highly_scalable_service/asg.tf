resource "aws_autoscaling_group" "steve1" {

  # Thie
  min_size             = 3
  max_size             = 6
  desired_capacity     = 3
  launch_configuration = aws_launch_configuration.steve1.name
  vpc_zone_identifier = data.aws_subnets.public_subnets.ids
}





# For ASG, we create an aws_autoscaling_attachment.  For EC2 instances, we create aws_lb_target_attachment since we know the EC2s in this case.
resource "aws_autoscaling_attachment" "steve1" {
  autoscaling_group_name = aws_autoscaling_group.steve1.id
  lb_target_group_arn   = aws_lb_target_group.HelloSteve-TG.arn
}