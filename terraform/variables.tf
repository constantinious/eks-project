# ------------------------------------------------------------------------------
# Root Variables
# All configurable values for the EKS portfolio project
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
# General
# ------------------------------------------------------------------------------
variable "aws_region" {
  description = "AWS region to deploy resources"
  type        = string
  default     = "eu-west-1"
}

variable "project_name" {
  description = "Name of the project, used for resource naming and tagging"
  type        = string
  default     = "eks-portfolio"
}

variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
  default     = "dev"

  validation {
    condition     = contains(["Dev", "Staging", "Prod"], var.environment)
    error_message = "Environment must be one of: Dev, Staging, Prod."
  }
}

variable "tags" {
  description = "Additional tags to apply to all resources"
  type        = map(string)
  default     = {}
}

# ------------------------------------------------------------------------------
# VPC
# ------------------------------------------------------------------------------
variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "availability_zones" {
  description = "List of availability zones to use"
  type        = list(string)
  default     = ["eu-west-1a", "eu-west-1b", "eu-west-1c"]
}

variable "private_subnet_cidrs" {
  description = "CIDR blocks for private subnets"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
}

variable "public_subnet_cidrs" {
  description = "CIDR blocks for public subnets"
  type        = list(string)
  default     = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]
}

variable "single_nat_gateway" {
  description = "Use a single NAT Gateway (cost optimization for dev)"
  type        = bool
  default     = true
}

variable "enable_vpc_flow_logs" {
  description = "Enable VPC Flow Logs for security auditing"
  type        = bool
  default     = true
}

# ------------------------------------------------------------------------------
# EKS
# ------------------------------------------------------------------------------
variable "cluster_version" {
  description = "Kubernetes version for the EKS cluster"
  type        = string
  default     = "1.32"
}

variable "cluster_endpoint_public_access" {
  description = "Enable public access to the EKS API server endpoint"
  type        = bool
  default     = true
}

variable "cluster_endpoint_private_access" {
  description = "Enable private access to the EKS API server endpoint"
  type        = bool
  default     = true
}

variable "cluster_endpoint_public_access_cidrs" {
  description = "CIDR blocks allowed to access the public EKS API endpoint"
  type        = list(string)
  default     = ["0.0.0.0/0"] # Restrict this in production
}

variable "additional_admin_arns" {
  description = "List of IAM user/role ARNs to grant cluster admin access (in addition to the Terraform user)"
  type        = list(string)
  default     = []
}

variable "node_instance_types" {
  description = "Instance types for the managed node group"
  type        = list(string)
  default     = ["t4g.small"]
}

variable "ami_type" {
  description = "AMI type for EKS nodes. Use AL2_ARM_64 for Graviton (t4g/m6g), AL2_x86_64 for x86"
  type        = string
  default     = "AL2_ARM_64"
}

variable "node_min_size" {
  description = "Minimum number of nodes in the managed node group"
  type        = number
  default     = 2
}

variable "node_max_size" {
  description = "Maximum number of nodes in the managed node group"
  type        = number
  default     = 10
}

variable "node_desired_size" {
  description = "Desired number of nodes in the managed node group"
  type        = number
  default     = 3
}

variable "node_disk_size" {
  description = "Disk size in GiB for worker nodes"
  type        = number
  default     = 50
}

variable "enable_cluster_autoscaler" {
  description = "Enable Cluster Autoscaler IRSA role and policies"
  type        = bool
  default     = true
}

variable "enabled_cluster_log_types" {
  description = "EKS control plane log types to enable (reduces CloudWatch costs when minimal)"
  type        = list(string)
  default     = ["api", "audit"] # Minimal set for cost optimization
}

# ------------------------------------------------------------------------------
# DNS & TLS
# ------------------------------------------------------------------------------
variable "domain_name" {
  description = "Domain name for the application (e.g., example.com)"
  type        = string
  default     = ""
}

variable "hosted_zone_id" {
  description = "Route53 hosted zone ID for the domain"
  type        = string
  default     = ""
}

variable "create_dns_resources" {
  description = "Whether to create Route53 and ACM resources"
  type        = bool
  default     = false
}

# ------------------------------------------------------------------------------
# ALB Controller
# ------------------------------------------------------------------------------
variable "alb_controller_version" {
  description = "Version of the AWS Load Balancer Controller Helm chart"
  type        = string
  default     = "1.10.1"
}

# ------------------------------------------------------------------------------
# Monitoring & Observability
# ------------------------------------------------------------------------------
variable "enable_monitoring" {
  description = "Enable the full monitoring stack (Prometheus, Grafana, Loki, Tempo)"
  type        = bool
  default     = false
}

variable "grafana_admin_password" {
  description = "Admin password for Grafana. Set via TF_VAR_grafana_admin_password or tfvars."
  type        = string
  default     = "changeme"
  sensitive   = true
}

variable "ebs_csi_driver_version" {
  description = "Version of the aws-ebs-csi-driver Helm chart"
  type        = string
  default     = "2.37.0"
}

variable "prometheus_stack_version" {
  description = "Version of the kube-prometheus-stack Helm chart"
  type        = string
  default     = "67.9.0"
}

variable "loki_version" {
  description = "Version of the Loki Helm chart"
  type        = string
  default     = "6.24.0"
}

variable "promtail_version" {
  description = "Version of the Promtail Helm chart"
  type        = string
  default     = "6.16.6"
}

variable "tempo_version" {
  description = "Version of the Tempo Helm chart"
  type        = string
  default     = "1.14.0"
}

variable "prometheus_retention" {
  description = "Prometheus data retention period"
  type        = string
  default     = "15d"
}

variable "prometheus_pvc_size" {
  description = "Prometheus PVC size"
  type        = string
  default     = "50Gi"
}

variable "grafana_pvc_size" {
  description = "Grafana PVC size"
  type        = string
  default     = "10Gi"
}

variable "loki_retention_days" {
  description = "Number of days to retain logs in Loki S3"
  type        = number
  default     = 30
}

variable "tempo_retention_days" {
  description = "Number of days to retain traces in Tempo S3"
  type        = number
  default     = 7
}

variable "monitoring_force_destroy" {
  description = "Allow force destroy of monitoring S3 buckets (useful for dev)"
  type        = bool
  default     = false
}

# ------------------------------------------------------------------------------
# ArgoCD (GitOps)
# ------------------------------------------------------------------------------
variable "enable_argocd" {
  description = "Enable ArgoCD EKS add-on for GitOps deployments"
  type        = bool
  default     = true
}

variable "argocd_chart_version" {
  description = "ArgoCD Helm chart version"
  type        = string
  default     = "7.7.15"
}

variable "argocd_enable_demo_app_sync" {
  description = "Enable automatic sync of demo app from Git"
  type        = bool
  default     = true
}

variable "argocd_git_repo_url" {
  description = "Git repository URL for ArgoCD to sync from"
  type        = string
  default     = "https://github.com/constantinious/eks-project.git"
}

variable "argocd_git_target_revision" {
  description = "Git branch/tag/commit for ArgoCD to track"
  type        = string
  default     = "main"
}

variable "argocd_git_manifests_path" {
  description = "Path in Git repo containing Kubernetes manifests"
  type        = string
  default     = "kubernetes/manifests"
}

variable "argocd_auto_prune" {
  description = "Automatically delete resources removed from Git"
  type        = bool
  default     = true
}

variable "argocd_auto_sync" {
  description = "Automatically sync when Git changes are detected"
  type        = bool
  default     = true
}
