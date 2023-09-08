# Create autoscaling group
resource "aws_autoscaling_group" "apache-asg" {
  name                      = "apache-asg"
  vpc_zone_identifier       = [aws_subnet.private_subnet_1.id, aws_subnet.private_subnet_2.id, aws_subnet.private_subnet_3.id]
  max_size                  = 5
  min_size                  = 2
  health_check_type         = "ELB"
  termination_policies = ["OldestInstance"]
  launch_template {
    id = aws_launch_template.apache-lt.id
    version = "$Latest"
  }

  target_group_arns = [aws_alb_target_group.alb-tg.arn]
}

# Create scaleout policy
resource "aws_autoscaling_policy" "apache_policy_up" {
  name = "apache_policy_up"
  scaling_adjustment = 1
  adjustment_type = "ChangeInCapacity"
  cooldown = 300
  autoscaling_group_name = aws_autoscaling_group.apache-asg.name
}

# Create scaleup alarm
resource "aws_cloudwatch_metric_alarm" "apache_cpu_alarm_up" {
  alarm_name = "apache_cpu_alarm_up"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods = 2
  period = 120
  threshold = 60
  metric_name = "CPUUtilization"
  namespace = "AWS/EC2"
  statistic  = "Average"

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.apache-asg.name
  }
  
  alarm_description = "This metric monitors ec2 cpu utilization"
  alarm_actions = [aws_autoscaling_policy.apache_policy_up.arn]
}

# Create scalein policy
resource "aws_autoscaling_policy" "apache_policy_down" {
  name = "apache_policy_down"
  scaling_adjustment = -1
  adjustment_type = "ChangeInCapacity"
  cooldown = 300
  autoscaling_group_name = aws_autoscaling_group.apache-asg.name
}

# Create scaledown alarm
resource "aws_cloudwatch_metric_alarm" "apache_cpu_alarm_down" {
  alarm_name = "apache_cpu_alarm_down"
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods = 2
  period = 120
  threshold = 10
  metric_name = "CPUUtilization"
  namespace = "AWS/EC2"
  statistic  = "Average"

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.apache-asg.name
  }
  
  alarm_description = "This metric monitors ec2 cpu utilization"
  alarm_actions = [aws_autoscaling_policy.apache_policy_down.arn]
}
