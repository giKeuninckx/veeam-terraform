### S3 bucket to store Veeam backups

resource "random_id" "veeam_aws_bucket_name_random_suffix" {
  byte_length = 8
}

resource "aws_s3_bucket" "veeam_aws_bucket" {
  bucket = "veeam-aws-bucket-demo-${lower(random_id.veeam_aws_bucket_name_random_suffix.hex)}"

  force_destroy = true
  # IMPORTANT! The bucket and all contents will be deleted upon running a `terraform destory` command

}

resource "aws_s3_bucket_public_access_block" "veeam_aws_bucket_public_access_block" {
  bucket = aws_s3_bucket.veeam_aws_bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_ownership_controls" "veeam_aws_bucket_ownership_controls" {
  bucket = aws_s3_bucket.veeam_aws_bucket.id

  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}

### S3 bucket lockdown

resource "aws_s3_bucket_policy" "veeam_aws_bucket_lockdown_policy" {
  bucket = aws_s3_bucket.veeam_aws_bucket.id
  policy = data.aws_iam_policy_document.veeam_aws_bucket_lockdown_policy_document.json
}

data "aws_iam_role" "admin_role_id" {
  name = var.admin_role
}

data "aws_iam_user" "admin_user_id" {
  user_name = var.admin_user
}

data "aws_iam_policy_document" "veeam_aws_bucket_lockdown_policy_document" {
  statement {
    effect = "Deny"

    principals {
      type        = "*"
      identifiers = ["*"]
    }

    actions = [
      "s3:*"
    ]

    resources = [
      aws_s3_bucket.veeam_aws_bucket.arn,
      "${aws_s3_bucket.veeam_aws_bucket.arn}/*",
    ]

    condition {
      test     = "StringNotLike"
      variable = "aws:userId"

      values = [
        "${data.aws_iam_role.admin_role_id.unique_id}:*",
        data.aws_iam_user.admin_user_id.user_id,
        "${aws_iam_role.veeam_aws_default_role.unique_id}:*"
      ]
    }
  }
}
