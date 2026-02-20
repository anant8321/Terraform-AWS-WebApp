resource "aws_autoscaling_policy" "scale-out" {
  name = "${var.project_name}-scale-out"
  autoscaling_group_name = var.asg_name
  adjustment_type = "ChangeInCapacity"
  scaling_adjustment = 1    # add 1 EC2 at a time
  cooldown = 300        # wait 5min(300s) before next scaling action
}

resource "aws_autoscaling_policy" "scale-in" {
  name = "${var.project_name}-scale-in"
  autoscaling_group_name = var.asg_name
  adjustment_type = "ChangeInCapacity"
  scaling_adjustment = -1   # remove 1 EC2 at a time
  cooldown = 300
}

# Scale-out trigger
resource "aws_cloudwatch_metric_alarm" "high-cpu" {
  alarm_name = "${var.project_name}-high-cpu"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods = 2
  metric_name = "CPUUtilization"
  namespace = "AWS/EC2"         # Where the metric comes from
  statistic = "Average"     # Takes average CPU of all EC2s in the ASG
  period = 120          
  threshold = 70

  dimensions = {
    AutoScalingGroupName = var.asg_name
  }

  alarm_actions = [ aws_autoscaling_policy.scale-out.arn ]
}

# Scale-in trigger
resource "aws_cloudwatch_metric_alarm" "low-cpu" {
  alarm_name = "${var.project_name}-low-cpu"
  comparison_operator = "LessThanThreshold"
  evaluation_periods = 2
  metric_name = "CPUUtilization"
  namespace = "AWS/EC2"         # Where the metric comes from
  statistic = "Average"     # Takes average CPU of all EC2s in the ASG
  period = 300
  threshold = 30

  dimensions = {
    AutoScalingGroupName = var.asg_name
  }

  alarm_actions = [ aws_autoscaling_policy.scale-in.arn ]
}