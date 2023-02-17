### Outputs

output "veeam_aws_instance_id" {
  description = "The instance ID of the Veeam Backup for AWS EC2 instance"
  value       = aws_instance.veeam_aws_instance.id
}

output "veeam_aws_instance_role_arn" {
  description = "The ARN of the instance role attached to the Veeam Backup for AWS EC2 instance"
  value       = aws_iam_role.veeam_aws_instance_role.arn
}

output "veeam_aws_bucket_name" {
  description = "The name of the provisioned S3 bucket"
  value       = aws_s3_bucket.veeam_aws_bucket.id
}