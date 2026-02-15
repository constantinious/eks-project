# ------------------------------------------------------------------------------
# Prod Environment - Terraform Variables
# High-availability production configuration
# ------------------------------------------------------------------------------

# General
aws_region   = "eu-west-1"
project_name = "eks-portfolio"
environment  = "Prod"

# VPC
vpc_cidr             = "10.1.0.0/16"
availability_zones   = ["eu-west-1a", "eu-west-1b", "eu-west-1c"]
private_subnet_cidrs = ["10.1.1.0/24", "10.1.2.0/24", "10.1.3.0/24"]
public_subnet_cidrs  = ["10.1.101.0/24", "10.1.102.0/24", "10.1.103.0/24"]
single_nat_gateway   = false # HA: one NAT Gateway per AZ
enable_vpc_flow_logs = true

# EKS
cluster_version                      = "1.29"
cluster_endpoint_public_access       = true
cluster_endpoint_private_access      = true
cluster_endpoint_public_access_cidrs = ["203.0.113.0/24"] # Restrict to your IP ranges

# Node Groups
node_instance_types       = ["t3.large"]
node_min_size             = 3
node_max_size             = 10
node_desired_size         = 3
node_disk_size            = 50
enable_cluster_autoscaler = true

# DNS
create_dns_resources = true
domain_name          = "example.com"
hosted_zone_id       = "Z0123456789ABCDEFGHIJ"

# ALB Controller
alb_controller_version = "1.10.1"

# Monitoring & Observability
enable_monitoring        = true
monitoring_force_destroy = false  # Protect production data
grafana_admin_password   = "changeme-prod"  # Override via TF_VAR_grafana_admin_password
prometheus_retention     = "30d"
prometheus_pvc_size      = "100Gi"
grafana_pvc_size         = "10Gi"
loki_retention_days      = 90
tempo_retention_days     = 14

# Additional tags
tags = {
  CostCenter = "production"
  Team       = "platform"
  Compliance = "required"
  Owner      = "constantinious"
  Service    = "eks-platform"
}
