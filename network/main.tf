terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = { source = "hashicorp/aws", version = ">= 4.0" }
  }
}

provider "aws" {
  region = var.aws_region
}

locals {
  tags = {
    Name       = "${var.user_prefix}.${var.tag_name}"
    owner      = var.tag_owner
    keep_until = var.tag_keep_until
  }
}

resource "aws_vpc" "vpc" {
  cidr_block = var.vpc_cidr
  tags       = local.tags

  enable_dns_support   = true
  enable_dns_hostnames = true
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id
  tags   = local.tags
}

resource "aws_subnet" "public" {
  count                   = length(var.public_subnet_cidrs)
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = var.public_subnet_cidrs[count.index]
  availability_zone       = var.azs[count.index]
  map_public_ip_on_launch = true
  tags = merge(local.tags, { Name = "${var.user_prefix}.${var.tag_name}-public-${count.index + 1}" })
}

resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.vpc.id
  tags = merge(local.tags, { Name = "${var.user_prefix}.${var.tag_name}-public-rt" })
}

resource "aws_route" "public_internet" {
  route_table_id         = aws_route_table.public_rt.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id
}

resource "aws_route_table_association" "public_assoc" {
  count          = length(var.public_subnet_cidrs)
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_security_group" "india_sg" {
  name        = "${var.user_prefix}.${var.tag_name}-india-sg"
  description = "This allows all inbound traffic from Mongo India - Gurugram and Bangalore offices. Note that CloudFlare Zero Trust CIDR is also added."
  vpc_id      = aws_vpc.vpc.id
  tags        = merge(local.tags, { Name = "${var.user_prefix}.${var.tag_name}-india-sg" })

  # For intra-VPC communication:
  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [aws_vpc.vpc.cidr_block]
    description = "Allow all traffic within the VPC"
  }

  dynamic "ingress" {
    for_each = var.allowed_ips
    content {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = [ingress.value.cidr]
      description = ingress.value.description
    }
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all outbound internet"
  }
}

