variable "user_prefix"   { description = "User prefix for all resource names and tags" }
variable "tag_name"       { description = "Resource name tag" }
variable "tag_owner"      { description = "Owner in first.last format" }
variable "tag_keep_until" { description = "Date until resource is to be kept (yyyy-mm-dd)" }

variable "aws_region"     { default = "ap-south-1" }

variable "ami_id" {
  default     = "ami-0af9569868786b23a"
  description = "Default AMI for EC2"
}
variable "instance_type" {
  default     = "t2.xlarge"
  description = "Default instance type for EC2"
}
variable "key_name" {
  default     = "AwsKey" #change to your key name
  description = "SSH key pair name"
}
variable "root_volume_size" {
  default     = 50
  description = "Root EBS volume size in GiB"
}
variable "root_volume_type" {
  default     = "gp3"
  description = "Root EBS volume type"
}
variable "instance_count" {
  description = "Number of EC2 instances to launch"
  default     = 1
}
variable "shutdown_cron_time" {
  description = "Cron time string for auto-shutdown (crontab format), e.g. '0 13 * * *' for 13:00 UTC. The cron job will be set by default."
  default     = "0 13 * * *"
}

