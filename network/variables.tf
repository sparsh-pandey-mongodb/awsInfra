variable "user_prefix"   { description = "User prefix for all resource names and tags" }
variable "tag_name"       { description = "Resource name tag" }
variable "tag_owner"      { description = "Owner in first.last format" }
variable "tag_keep_until" { description = "Date until resource is to be kept (yyyy-mm-dd)" }

variable "aws_region"         { default = "ap-south-1" }
variable "vpc_cidr"           { default = "10.10.0.0/16" }
variable "public_subnet_cidrs" { default = ["10.10.1.0/24", "10.10.2.0/24", "10.10.3.0/24"] }
variable "azs" {
  default = ["ap-south-1a", "ap-south-1b", "ap-south-1c"]
}
variable "allowed_ips" {
  description = "List of india/VDI source CIDR blocks"
  type = list(object({ cidr = string, description = string }))
  default = [
    { cidr = "182.76.117.48/29", description = "Gurugram / Airtel" },
    { cidr = "14.98.65.56/29", description = "Gurugram / Tata" },
    { cidr = "13.201.114.222/32", description = "ap-south-1 VDIs" },
    { cidr = "14.195.102.136/29", description = "Bangalore / Tata" },
    { cidr = "61.246.212.64/29", description = "Bangalore / Airtel" },
    { cidr = "104.30.164.0/28", description = "Global Cloudflare IP range"}
  ]
}

