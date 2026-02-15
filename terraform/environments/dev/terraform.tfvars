# ------------------------------------------------------------------------------
# Dev Environment - Terraform Variables
# Cost-optimized configuration for development
# ------------------------------------------------------------------------------

# General
aws_region   = "eu-west-1"
project_name = "eks-portfolio"
environment  = "Dev"

# VPC
vpc_cidr             = "10.0.0.0/16"
availability_zones   = ["eu-west-1a", "eu-west-1b", "eu-west-1c"]
private_subnet_cidrs = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
public_subnet_cidrs  = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]
single_nat_gateway   = true # Cost optimization: single NAT for dev
enable_vpc_flow_logs = true

# EKS
cluster_version                      = "1.29"
cluster_endpoint_public_access       = true
cluster_endpoint_private_access      = true
cluster_endpoint_public_access_cidrs = ["0.0.0.0/0"] # Restrict in production!

# Node Groups
node_instance_types    = ["t4g.medium"]
node_min_size          = 2
node_max_size          = 5
node_desired_size      = 2
node_disk_size         = 30
enable_cluster_autoscaler = true

# DNS (set to true and configure when you have a domain)
create_dns_resources = false
# domain_name        = "dev.example.com"
# hosted_zone_id     = "Z0123456789ABCDEFGHIJ"

# ALB Controller
alb_controller_version = "1.10.1"

# Additional tags
tags = {
  CostCenter = "development"
  Team       = "platform"
  Owner      = "constantinious"
}
