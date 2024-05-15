data "aws_subnets" "private_subnets" {
  filter {
    name   = "vpc-id"
    values = [var.vpc_id]
  }

  tags = {
    Type = "Private"
  }
}

# We put our EC2 in the PRIVATE subnets and asccess via LB in public
resource "aws_autoscaling_group" "steve1" {

  min_size             = length(data.aws_subnets.private_subnets.ids)
  max_size             = 6
  desired_capacity     = length(data.aws_subnets.private_subnets.ids)
  launch_configuration = aws_launch_configuration.steve1.name
  vpc_zone_identifier = data.aws_subnets.private_subnets.ids
  

  tag {
     key                 = "Name"
     value               = var.project_name
     propagate_at_launch = true
   }
}


# For ASG, we create an aws_autoscaling_attachment.  For EC2 instances, we create aws_lb_target_attachment since we know the EC2s in this case.
resource "aws_autoscaling_attachment" "steve1" {
  autoscaling_group_name = aws_autoscaling_group.steve1.id
  lb_target_group_arn   = aws_lb_target_group.HelloSteve-TG.arn
}

# For testing, created a policy to increase EC2 instanes when CPU > 40%
# Added this as a test so we can run stress to see if ASG kicks in
/*
resource "aws_autoscaling_policy" "example" {
  name  = "SteveASGPolicy"
  policy_type            = "TargetTrackingScaling"
  autoscaling_group_name = aws_autoscaling_group.steve1.name
  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }

    target_value = 40.0
  }
}*/