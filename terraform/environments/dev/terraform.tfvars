# ------------------------------------------------------------------------------
# Dev Environment - Ultra-Minimal Cost Configuration
# Optimized for home projects and cost reduction
# 
# Cost optimizations applied:
# - 2 AZs instead of 3 (reduces networking complexity)
# - t4g.small instances (ARM Graviton, cheapest compute)
# - 1-3 nodes (minimal capacity, can scale up if needed)
# - 20GB disk (minimal EBS storage)
# - Monitoring stack DISABLED (saves ~$50-100/month)
# - VPC Flow Logs disabled (reduces CloudWatch costs)
# - Single NAT Gateway (cost optimization)
# ------------------------------------------------------------------------------

# General
aws_region   = "eu-west-1"
project_name = "eks-portfolio"
environment  = "Dev"

# VPC (minimal cost: 2 AZs only)
vpc_cidr             = "10.0.0.0/16"
availability_zones   = ["eu-west-1a", "eu-west-1b"]
private_subnet_cidrs = ["10.0.1.0/24", "10.0.2.0/24"]
public_subnet_cidrs  = ["10.0.101.0/24", "10.0.102.0/24"]
single_nat_gateway   = true  # Cost optimization: single NAT for dev
enable_vpc_flow_logs = false # Disable to reduce CloudWatch costs

# EKS (minimal cost configuration)
cluster_version                      = "1.31"
cluster_endpoint_public_access       = true
cluster_endpoint_private_access      = true
cluster_endpoint_public_access_cidrs = ["0.0.0.0/0"] # Restrict in production!
enabled_cluster_log_types            = ["api"]       # Minimal logging to reduce CloudWatch costs
additional_admin_arns                = ["arn:aws:iam::992382750905:user/KostasAdmin"] # Additional cluster admins

# Node Groups (minimal cost: t4g.small, 1-3 nodes)
node_instance_types       = ["t4g.small"]
node_min_size             = 1
node_max_size             = 3
node_desired_size         = 2
node_disk_size            = 20
enable_cluster_autoscaler = true

# DNS (set to true and configure when you have a domain)
create_dns_resources = false
# domain_name        = "dev.example.com"
# hosted_zone_id     = "Z0123456789ABCDEFGHIJ"

# ALB Controller
alb_controller_version = "1.10.1"

# Monitoring & Observability (disabled for cost optimization)
enable_monitoring        = false          # Disable to save costs
monitoring_force_destroy = true           # Allow bucket deletion in dev
grafana_admin_password   = "changeme-dev" # Override via TF_VAR_grafana_admin_password
prometheus_retention     = "3d"           # Minimal retention
prometheus_pvc_size      = "10Gi"         # Minimal PVCs
grafana_pvc_size         = "2Gi"
loki_retention_days      = 7 # 1 week for dev
tempo_retention_days     = 1 # 1 day for dev

# Additional tags
tags = {
  CostCenter = "development"
  Team       = "platform"
  Owner      = "constantinious"
  Service    = "eks-platform"
}
