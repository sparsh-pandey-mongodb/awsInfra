# Terraform Modular AWS Network & EC2 Deployment (India Offices)  
  
## Overview  
  
This repository contains a modular, production-grade Terraform setup for deploying AWS VPC infrastructure and EC2 instances, using best practices for reusability and separation of environments.  
  
**Key Features:**  
- **Network Stack** (`/network`):    
    - Creates a VPC in `ap-south-1` (Mumbai)  
    - 3 public subnets (1 per AZ)  
    - Internet Gateway and Route Table 
    - Security Group allowing only whitelisted India office, VDI, and Cloudflare IPs
    - DNS support & DNS hostnames enabled by default
    - Standardized tagging throughout
  
- **Compute Stack** (`/ec2_instance`):    
    - One or more EC2 instances launched in the VPC   
    - Uses the network stack’s Security Group & public subnet  
    - References network outputs via Terraform remote state
    - Attaches a cron job for automatic daily shutdown (/sbin/shutdown -h now by default at 13:00UTC). This time is easily configurable via a Terraform variable (shutdown_cron_time)
  
All Terraform resource blocks use the format `<user_prefix>.<resource_type>` for easy identification and search in code and in AWS.  
  
---  
  
## Repository Structure  

 ```
terraform  
├── ec2_instance  
│   ├── main.tf  
│   ├── outputs.tf  
│   ├── terraform.tfvars  
│   └── variables.tf  
├── network  
│   ├── main.tf  
│   ├── outputs.tf  
│   ├── terraform.tfvars  
│   └── variables.tf  
└── README.md  
```  
---  
  
## Prerequisites  
  
- [Terraform CLI](https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli) installed (v1.0+)  
- An AWS account with sufficient IAM permissions (VPC and EC2 API access)  
- AWS credentials set (via environment variables or [AWS profiles](https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-profiles.html)), **never stored in Terraform files**  
  
---  
  
## Variable and Tagging Approach  
  
All resources accept the following variables for tags:  
  
| Variable          | Description                                          | Example Usage           |  
|-------------------|------------------------------------------------------|-------------------------|  
| `tag_name`        | Identifies the infrastructure resource group         | `sparsh-vpc`       |  
| `tag_owner`       | Who owns/created the resource (first.last)           | `myname.surname`        |  
| `tag_keep_until`  | When resource can be auto-cleaned (for governance)   | `2024-09-01`            |  
  
*Values are set in `terraform.tfvars` in each module, and applied via local.tags.*  
  
---  
  
## Usage: Step by Step  
  
### 1. **Provisioning the Network Layer (One-time)**  
  
```sh  
cd terraform/network  
terraform init  
terraform apply  
```

Edit `terraform.tfvars` in the network folder if you want to change tags, CIDRs, or allowed IPs.
This stack creates the VPC, subnets, IGW, route, and office security group.
Only do a destroy here if you want to remove the entire network stack.

2. Managing EC2 Instances (Create/Destroy at will)
```sh
cd ../ec2_instance  
terraform init  
terraform apply  
```

This will read outputs from the network stack (remote state) and launch an EC2 in the public subnet with your security group.
Edit `terraform.tfvars` here to set EC2 tag_name, owner, keep_until, AMI, or instance type.
To clean up all EC2s but keep your network, simply:
`terraform destroy`

3. Destroying all infrastructure
Always destroy the EC2 stack first, then the network stack:

```sh
cd ../ec2_instance  
terraform destroy  
cd ../network  
terraform destroy  
```

4. Auto-shutdown cron-job

Each EC2 instance will have a daily cron job configured to automatically shut down the instance at a specified UTC time.

Default time: `13:00 UTC (1 PM UTC)`
Command: `/sbin/shutdown -h now`

Change the shutdown time:
    Edit the shutdown_cron_time in terraform/ec2_instance/terraform.tfvars, for example:
    shutdown_cron_time = "0 21 * * *" # 21:00 UTC = 9 PM UTC daily   
    Format: crontab syntax 
    The system time zone is UTC by default on Amazon Linux/Ubuntu cloud VMs.
    If you want to remove or customize the behavior, edit the user_data section in ec2_instance/main.tf.


--------

# Frequently Asked Questions

Q: How do I update tags or allowed CIDRs?
Edit the relevant variable or values in the appropriate terraform.tfvars or variables.tf, then rerun terraform apply.

Q: How do I launch more than one EC2?
Use the count variable for scaling.


Security Group CIDRs
Only these are allowed inbound and outbound (per your requirements):

Link referred - https://iteng-officeips.officeit.prod.corp.mongodb.com/

```sh
Gurugram (Airtel & Tata)
Bangalore (Airtel & Tata)
CloudFlare
```

If you need additional CIDRs, add them to the allowed_ips default in `network/variables.tf`.

# Customization/Extension
- Change subnets or regions: Edit azs and `public_subnet_cidrs` in `network/variables.tf`
- Change EC2 AMI or type: Edit variables in `ec2_instance/variables.tf` or set in your `terraform.tfvars`

# Troubleshooting
- If tags or resources appear missing: Double-check your values in terraform.tfvars
- State errors: Ensure you apply network before EC2, and never destroy the network stack first.
- Credential errors: Credentials must be set in environment or AWS profile before running Terraform.


### Created & Managed by "MongoDB Technical Services Team - Infrastructure"

