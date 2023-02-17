### IAM Resources

data "aws_iam_policy_document" "veeam_aws_instance_role_assume_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "veeam_aws_instance_role_inline_policy" {
  statement {
    actions   = ["sts:AssumeRole"]
    resources = ["*"]
  }
}

resource "aws_iam_role" "veeam_aws_instance_role" {
  name               = "veeam-aws-instance-role"
  assume_role_policy = data.aws_iam_policy_document.veeam_aws_instance_role_assume_policy.json

  inline_policy {
    name   = "veeam-aws-instance-policy"
    policy = data.aws_iam_policy_document.veeam_aws_instance_role_inline_policy.json
  }
}

resource "aws_iam_instance_profile" "veeam_aws_instance_profile" {
  name = "veeam-aws-instance-profile"
  role = aws_iam_role.veeam_aws_instance_role.name
}

data "aws_iam_policy_document" "veeam_aws_default_role_assume_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["backup.amazonaws.com"]
    }

    principals {
      type        = "AWS"
      identifiers = [aws_iam_role.veeam_aws_instance_role.arn]
    }
  }
}

resource "aws_iam_role" "veeam_aws_default_role" {
  name               = "veeam-aws-default-role"
  assume_role_policy = data.aws_iam_policy_document.veeam_aws_default_role_assume_policy.json
}

resource "aws_iam_policy" "veeam_aws_service_policy" {
  name        = "veeam-aws-service-policy"
  description = "Veeam Backup for AWS permissions to launch worker instances to perform backup and restore operations."

  policy = file("veeam-aws-service-policy.json")
}

resource "aws_iam_role_policy_attachment" "veeam_aws_service_policy_attachment" {
  role       = aws_iam_role.veeam_aws_default_role.name
  policy_arn = aws_iam_policy.veeam_aws_service_policy.arn
}

resource "aws_iam_policy" "veeam_aws_repository_policy" {
  name        = "veeam-aws-repository-policy"
  description = "Veeam Backup for AWS permissions to create backup repositories in an Amazon S3 bucket and to access the repository when performing backup and restore operations."

  policy = file("veeam-aws-repository-policy.json")
}

resource "aws_iam_role_policy_attachment" "veeam_aws_repository_policy_attachment" {
  role       = aws_iam_role.veeam_aws_default_role.name
  policy_arn = aws_iam_policy.veeam_aws_repository_policy.arn
}