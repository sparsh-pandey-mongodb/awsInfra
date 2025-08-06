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

data "terraform_remote_state" "network" {
  backend = "local"
  config = {
    path = "../network/terraform.tfstate"
  }
}

resource "aws_instance" "ec2" {
  count                       = var.instance_count
  ami                         = var.ami_id
  instance_type               = var.instance_type
  subnet_id                   = data.terraform_remote_state.network.outputs.public_subnet_ids[0]
  vpc_security_group_ids      = [data.terraform_remote_state.network.outputs.sg_id]
  associate_public_ip_address = true
  key_name                    = var.key_name
  root_block_device {
    volume_size = var.root_volume_size
    volume_type = var.root_volume_type
    delete_on_termination = true
  }

user_data = <<EOF
#!/bin/bash
set -xe

# Install cronie and start crond for cron support
yum install -y cronie

systemctl enable crond
systemctl start crond

# The following cron job will automatically shutdown the instance every day at the time specified by the shutdown_cron_time variable.
# By default: 0 13 * * *  = 13:00 UTC = 1 PM UTC
# To change the shutdown time, set the shutdown_cron_time Terraform variable (in crontab format)
# Example: 0 21 * * * = 21:00 UTC = 9 PM UTC
echo "${var.shutdown_cron_time} /sbin/shutdown -h now" | crontab -
crontab -l

EOF

  tags = merge(
    local.tags,
    { Name = "${var.user_prefix}.${var.tag_name}-ec2-${count.index + 1}" }
  )
}

