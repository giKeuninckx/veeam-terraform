### VPC Resources

resource "aws_vpc" "veeam_aws_vpc" {
  cidr_block           = var.vpc_cidr_block_ipv4
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "veeam-aws-vpc"
  }
}

resource "aws_internet_gateway" "veeam_aws_igw" {
  tags = {
    Name = "veeam-aws-igw"
  }
}

resource "aws_internet_gateway_attachment" "veeam_aws_igw_attachment" {
  internet_gateway_id = aws_internet_gateway.veeam_aws_igw.id
  vpc_id              = aws_vpc.veeam_aws_vpc.id
}

resource "aws_route_table" "veeam_aws_route_table" {
  vpc_id = aws_vpc.veeam_aws_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.veeam_aws_igw.id
  }

  tags = {
    Name = "veeam-aws-rt"
  }
}

resource "aws_route_table_association" "veeam_aws_route_table_association" {
  subnet_id      = aws_subnet.veeam_aws_subnet.id
  route_table_id = aws_route_table.veeam_aws_route_table.id
}

resource "aws_subnet" "veeam_aws_subnet" {
  vpc_id                  = aws_vpc.veeam_aws_vpc.id
  cidr_block              = var.subnet_cidr_block_ipv4
  map_public_ip_on_launch = true

  tags = {
    Name = "veeam-aws-subnet"
  }
}

resource "aws_security_group" "veeam_aws_security_group" {
  name        = "veeam-aws-security-group"
  description = "Access to Veeam Backup for AWS appliance"
  vpc_id      = aws_vpc.veeam_aws_vpc.id

  ingress {
    description = "HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [var.veeam_aws_security_group]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_vpc_endpoint" "veeam_aws_s3_endpoint" {
  vpc_id            = aws_vpc.veeam_aws_vpc.id
  vpc_endpoint_type = "Gateway"
  service_name      = "com.amazonaws.${var.aws_region}.s3"
  route_table_ids   = [aws_route_table.veeam_aws_route_table.id]
}

resource "aws_eip" "veeam_aws_eip" {
  count = var.elastic_ip ? 1 : 0
  vpc   = true
}

resource "aws_eip_association" "veeam_aws_eip_association" {
  count         = var.elastic_ip ? 1 : 0
  instance_id   = aws_instance.veeam_aws_instance.id
  allocation_id = aws_eip.veeam_aws_eip[0].id
}