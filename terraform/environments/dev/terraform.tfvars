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
cluster_version                      = "1.35"
cluster_endpoint_public_access       = true
cluster_endpoint_private_access      = true
cluster_endpoint_public_access_cidrs = ["0.0.0.0/0"]                                  # ⚠️ SECURITY: Restrict to your IP in production!
enabled_cluster_log_types            = ["api"]                                        # Minimal logging to reduce CloudWatch costs
additional_admin_arns                = []  # ⚠️ REQUIRED: Add your IAM admin ARNs here for kubectl access

# Node Groups (with monitoring: t4g.medium for 4GB RAM, 2-5 nodes)
node_instance_types       = ["t4g.medium"]  # 4GB RAM needed for monitoring stack
node_min_size             = 2
node_max_size             = 5
node_desired_size         = 3  # Start with 3 nodes for monitoring
node_disk_size            = 20
enable_cluster_autoscaler = true

# DNS (ExternalDNS configuration)
create_dns_resources = true
domain_name          = "example.com"  # ⚠️ REQUIRED: Replace with your actual domain (e.g., "myportfolio.com")
hosted_zone_id       = "ZXXXXXXXXXXXXX"  # ⚠️ REQUIRED: Replace with your Route53 hosted zone ID (e.g., "Z0123456789ABCDEF")

# ArgoCD (GitOps - automatic deployment from Git)
enable_argocd                = true
argocd_enable_demo_app_sync  = true
argocd_git_repo_url          = "https://github.com/constantinious/eks-project.git"
argocd_git_target_revision   = "main"
argocd_git_manifests_path    = "kubernetes/manifests"
argocd_auto_prune            = true  # Delete resources removed from Git
argocd_auto_sync             = true  # Auto-deploy when Git changes

# ALB Controller
alb_controller_version = "1.10.1"

# Monitoring & Observability
enable_monitoring        = true           # Enable Prometheus, Grafana, Loki, Tempo stack
monitoring_force_destroy = true           # Allow bucket deletion in dev
grafana_admin_password   = "CHANGE_ME"    # ⚠️ SECURITY: NEVER commit real passwords! Set via: export TF_VAR_grafana_admin_password="your-secure-password"
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
