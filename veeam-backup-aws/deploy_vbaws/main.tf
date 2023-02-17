terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.30"
    }

    random = {
      source  = "hashicorp/random"
      version = "~> 3.4.3"
    }
  }

  required_version = ">= 1.2.0"
}

provider "aws" {
  region  = var.aws_region
}

locals {
  veeam_aws_instance_ami      = var.veeam_aws_edition == "byol" ? local.veeam_aws_instance_ami_byol : (var.veeam_aws_edition == "free" ? local.veeam_aws_instance_ami_free : local.veeam_aws_instance_ami_paid)
  veeam_aws_instance_ami_free = lookup(var.veeam_aws_free_edition_ami_map, var.aws_region)
  veeam_aws_instance_ami_byol = lookup(var.veeam_aws_byol_edition_ami_map, var.aws_region)
  veeam_aws_instance_ami_paid = lookup(var.veeam_aws_paid_edition_ami_map, var.aws_region)
}
### EC2 Resources

resource "aws_instance" "veeam_aws_instance" {
  ami                    = local.veeam_aws_instance_ami
  instance_type          = var.veeam_aws_instance_type
  iam_instance_profile   = aws_iam_instance_profile.veeam_aws_instance_profile.name
  subnet_id              = aws_subnet.veeam_aws_subnet.id
  vpc_security_group_ids = [aws_security_group.veeam_aws_security_group.id]

  tags = {
    Name = "veeam-aws-demo"
  }

  user_data = join("\n", [aws_iam_role.veeam_aws_instance_role.arn, aws_iam_role.veeam_aws_default_role.arn])
}