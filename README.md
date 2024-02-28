
Requirements:
- EKS in Stockholm (eu-north-1)
- Single Egress IP: ensure a single IP for outbound cluster traffic
- Multi-Region, multi-environment directory structure

Prerequisites:
- AWS Account: With permissions to deploy resources (EKS, EC2, VPC, etc.)
- Terraform: Installed on your system
- AWS CLI: Configured with your AWS credentials.

Terraform directory structure:
> modules:
  - eks: defines EKS cluster configuration:
    Create the EKS cluster, specifying the VPC and subnets.
    Create worker node groups associated with the VPC and subnets.
    Ensure worker nodes use a launch configuration configured to pass the correct private subnets to ensure traffic is routed through the NAT Gateway.
    
  - nat: configures the NAT Gateway logic:
    Allocate an Elastic IP address.
    Create a NAT Gateway in a public subnet.
    Update the route table for private subnets to use the NAT Gateway.
    
  - vpc: manages VPC, subnets, route tables:
    Create VPC, public and private subnets, Internet Gateway.
    Set up route tables to direct internet traffic from private subnets via a NAT Gateway.

> regions: holds region-specific TF configurations
Each region has its own main.tf and environment-specific .tfvars files for customization.
Call the VPC, NAT Gateway, and EKS modules.
Use terraform workspace to manage production and testing environments.

> variables.tf: stores common variables used across the project - region, environment, VPC CIDR, subnet CIDRs, EKS cluster name, etc.

> providers.tf: defines the AWS provider and other required providers

Region Configuration (regions/eu-north-1/main.tf)

Deployment:
Initialize Terraform in each region directory.
Use terraform workspace select to choose the environment.
Run terraform plan and terraform apply.
