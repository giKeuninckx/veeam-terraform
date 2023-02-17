### CloudWatch alarms and Data Lifecycle Manager policy

resource "aws_cloudwatch_metric_alarm" "veeam_aws_recovery_alarm" {
  alarm_name          = "veeam-aws-recovery-alarm"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "StatusCheckFailed_System"
  namespace           = "AWS/EC2"
  period              = "60"
  statistic           = "Minimum"
  threshold           = "0"
  alarm_description   = "Trigger a recovery when system status check fails for 15 consecutive minutes."
  alarm_actions       = ["arn:aws:automate:${var.aws_region}:ec2:recover"]
  dimensions          = { InstanceId : aws_instance.veeam_aws_instance.id }
}

resource "aws_cloudwatch_metric_alarm" "veeam_aws_reboot_alarm" {
  alarm_name          = "veeam-aws-reboot-alarm"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "3"
  metric_name         = "StatusCheckFailed_Instance"
  namespace           = "AWS/EC2"
  period              = "60"
  statistic           = "Minimum"
  threshold           = "0"
  alarm_description   = "Trigger a reboot when instance status check fails for 3 consecutive minutes."
  alarm_actions       = ["arn:aws:automate:${var.aws_region}:ec2:reboot"]
  dimensions          = { InstanceId : aws_instance.veeam_aws_instance.id }
}

resource "aws_dlm_lifecycle_policy" "veeam_aws_dlm_lifecycle_policy" {
  description        = "DLM policy for the Veeam Backup for AWS EC2 instance"
  execution_role_arn = aws_iam_role.veeam_aws_dlm_role.arn
  state              = "ENABLED"

  policy_details {
    resource_types = ["INSTANCE"]

    schedule {
      name = "Daily snapshots"

      create_rule {
        interval      = 12
        interval_unit = "HOURS"
        times         = ["03:00"]
      }

      retain_rule {
        count = 1
      }

      tags_to_add = {
        type = "VcbDailySnapshot"
      }

      copy_tags = true
    }

    target_tags = {
      Name = "veeam-aws-demo"
    }
  }
}
