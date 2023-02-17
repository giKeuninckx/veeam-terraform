## Backup policies

resource "aws_iam_policy" "veeam_aws_ec2_backup_policy" {
  name        = "veeam-aws-ec2-backup-policy"
  description = "Veeam Backup for AWS permissions to execute policies for EC2 data protection."

  policy = file("veeam-aws-ec2-backup-policy.json")
}

resource "aws_iam_role_policy_attachment" "veeam_aws_ec2_backup_policy_attachment" {
  role       = aws_iam_role.veeam_aws_default_role.name
  policy_arn = aws_iam_policy.veeam_aws_ec2_backup_policy.arn
}

resource "aws_iam_policy" "veeam_aws_rds_backup_policy" {
  name        = "veeam-aws-rds-backup-policy"
  description = "Veeam Backup for AWS permissions to execute policies for RDS data protection."

  policy = file("veeam-aws-rds-backup-policy.json")
}

resource "aws_iam_role_policy_attachment" "veeam_aws_rds_backup_policy_attachment" {
  role       = aws_iam_role.veeam_aws_default_role.name
  policy_arn = aws_iam_policy.veeam_aws_rds_backup_policy.arn
}

resource "aws_iam_policy" "veeam_aws_efs_backup_policy" {
  name        = "veeam-aws-efs-backup-policy"
  description = "Veeam Backup for AWS permissions to execute policies for EFS data protection."

  policy = file("veeam-aws-efs-backup-policy.json")
}

resource "aws_iam_role_policy_attachment" "veeam_aws_efs_backup_policy_attachment" {
  role       = aws_iam_role.veeam_aws_default_role.name
  policy_arn = aws_iam_policy.veeam_aws_efs_backup_policy.arn
}

resource "aws_iam_policy" "veeam_aws_vpc_backup_policy" {
  name        = "veeam-aws-vpc-backup-policy"
  description = "Veeam Backup for AWS permissions to execute policies for VPC configuration backup."

  policy = file("veeam-aws-vpc-backup-policy.json")
}

resource "aws_iam_role_policy_attachment" "veeam_aws_vpc_backup_policy_attachment" {
  role       = aws_iam_role.veeam_aws_default_role.name
  policy_arn = aws_iam_policy.veeam_aws_vpc_backup_policy.arn
}

## Restore policies

resource "aws_iam_policy" "veeam_aws_ec2_restore_policy" {
  name        = "veeam-aws-ec2-restore-policy"
  description = "Veeam Backup for AWS permissions to perform EC2 restore operations."

  policy = file("veeam-aws-ec2-restore-policy.json")
}

resource "aws_iam_role_policy_attachment" "veeam_aws_ec2_restore_policy_attachment" {
  role       = aws_iam_role.veeam_aws_default_role.name
  policy_arn = aws_iam_policy.veeam_aws_ec2_restore_policy.arn
}

resource "aws_iam_policy" "veeam_aws_rds_restore_policy" {
  name        = "veeam-aws-rds-restore-policy"
  description = "Veeam Backup for AWS permissions to perform RDS restore operations."

  policy = file("veeam-aws-rds-restore-policy.json")
}

resource "aws_iam_role_policy_attachment" "veeam_aws_rds_restore_policy_attachment" {
  role       = aws_iam_role.veeam_aws_default_role.name
  policy_arn = aws_iam_policy.veeam_aws_rds_restore_policy.arn
}

resource "aws_iam_policy" "veeam_aws_efs_restore_policy" {
  name        = "veeam-aws-efs-restore-policy"
  description = "Veeam Backup for AWS permissions to perform EFS restore operations."

  policy = file("veeam-aws-efs-restore-policy.json")
}

resource "aws_iam_role_policy_attachment" "veeam_aws_efs_restore_policy_attachment" {
  role       = aws_iam_role.veeam_aws_default_role.name
  policy_arn = aws_iam_policy.veeam_aws_efs_restore_policy.arn
}

resource "aws_iam_policy" "veeam_aws_vpc_restore_policy" {
  name        = "veeam-aws-vpc-restore-policy"
  description = "Veeam Backup for AWS permissions to perform VPC configuration restore operations."

  policy = file("veeam-aws-vpc-restore-policy.json")
}

resource "aws_iam_role_policy_attachment" "veeam_aws_vpc_restore_policy_attachment" {
  role       = aws_iam_role.veeam_aws_default_role.name
  policy_arn = aws_iam_policy.veeam_aws_vpc_restore_policy.arn
}

resource "aws_iam_role" "veeam_aws_dlm_role" {
  name = "veeam-aws-dlm-role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",      
      "Principal": {
        "Service": "dlm.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "veeam_aws_dlm_role_policy" {
  name = "veeam-aws-dlm-role-policy"
  role = aws_iam_role.veeam_aws_dlm_role.id

  policy = <<EOF
{
   "Version": "2012-10-17",
   "Statement": [
      {
         "Effect": "Allow",
         "Action": [
            "ec2:CreateSnapshot",
            "ec2:CreateSnapshots",
            "ec2:DescribeInstances",
            "ec2:DescribeVolumes",
            "ec2:DescribeSnapshots"
         ],
         "Resource": "*"
      },
      {
         "Effect": "Allow",
         "Action": [
            "ec2:CreateTags",
            "ec2:DeleteSnapshot"
         ],
         "Resource": "arn:aws:ec2:*::snapshot/*"
      }
   ]
}
EOF
}