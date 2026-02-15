# ------------------------------------------------------------------------------
# Root Module
# Wires together all sub-modules to create a production-ready EKS cluster
# on AWS with ALB Controller, ExternalDNS, and full security posture.
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
# Provider Configuration
# Locally: export AWS_PROFILE=terraform_user before running terraform
# CI: credentials are injected via OIDC (configure-aws-credentials action)
# ------------------------------------------------------------------------------
provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Environment = var.environment
      Project     = var.project_name
      ManagedBy   = "terraform"
      Repository  = "eks-portfolio-project"
    }
  }
}

provider "kubernetes" {
  host                   = module.eks.cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)

  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command     = "aws"
    args        = ["eks", "get-token", "--cluster-name", local.cluster_name, "--region", var.aws_region]
  }
}

provider "helm" {
  kubernetes {
    host                   = module.eks.cluster_endpoint
    cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)

    exec {
      api_version = "client.authentication.k8s.io/v1beta1"
      command     = "aws"
      args        = ["eks", "get-token", "--cluster-name", local.cluster_name, "--region", var.aws_region]
    }
  }
}

# ------------------------------------------------------------------------------
# Locals
# ------------------------------------------------------------------------------
locals {
  cluster_name = "${var.project_name}-${var.environment}"

  common_tags = merge(var.tags, {
    Environment = var.environment
    Project     = var.project_name
    ManagedBy   = "terraform"
  })
}

# ------------------------------------------------------------------------------
# VPC Module
# ------------------------------------------------------------------------------
module "vpc" {
  source = "./modules/vpc"

  project_name         = var.project_name
  environment          = var.environment
  vpc_cidr             = var.vpc_cidr
  availability_zones   = var.availability_zones
  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
  single_nat_gateway   = var.single_nat_gateway
  enable_vpc_flow_logs = var.enable_vpc_flow_logs
  cluster_name         = local.cluster_name
  tags                 = local.common_tags
}

# ------------------------------------------------------------------------------
# Security Module
# ------------------------------------------------------------------------------
module "security" {
  source = "./modules/security"

  project_name = var.project_name
  environment  = var.environment
  vpc_id       = module.vpc.vpc_id
  cluster_name = local.cluster_name
  tags         = local.common_tags
}

# ------------------------------------------------------------------------------
# EKS Module
# ------------------------------------------------------------------------------
module "eks" {
  source = "./modules/eks"

  cluster_name                         = local.cluster_name
  cluster_version                      = var.cluster_version
  environment                          = var.environment
  private_subnet_ids                   = module.vpc.private_subnet_ids
  public_subnet_ids                    = module.vpc.public_subnet_ids
  cluster_security_group_id            = module.security.eks_cluster_security_group_id
  node_security_group_id               = module.security.eks_nodes_security_group_id
  kms_key_arn                          = module.security.eks_kms_key_arn
  ebs_kms_key_arn                      = module.security.ebs_kms_key_arn
  cluster_endpoint_private_access      = var.cluster_endpoint_private_access
  cluster_endpoint_public_access       = var.cluster_endpoint_public_access
  cluster_endpoint_public_access_cidrs = var.cluster_endpoint_public_access_cidrs
  additional_admin_arns                = var.additional_admin_arns
  node_instance_types                  = var.node_instance_types
  ami_type                             = var.ami_type
  node_min_size                        = var.node_min_size
  node_max_size                        = var.node_max_size
  node_desired_size                    = var.node_desired_size
  node_disk_size                       = var.node_disk_size
  enable_cluster_autoscaler            = var.enable_cluster_autoscaler
  enabled_cluster_log_types            = var.enabled_cluster_log_types
  tags                                 = local.common_tags
}

# ------------------------------------------------------------------------------
# ALB Controller Module
# ------------------------------------------------------------------------------
module "alb_controller" {
  source = "./modules/alb-controller"

  cluster_name      = module.eks.cluster_name
  aws_region        = var.aws_region
  vpc_id            = module.vpc.vpc_id
  oidc_provider_arn = module.eks.oidc_provider_arn
  oidc_provider_url = module.eks.oidc_provider_url
  chart_version     = var.alb_controller_version
  tags              = local.common_tags
}

# ------------------------------------------------------------------------------
# Route53 Module (optional - only when DNS is configured)
# ------------------------------------------------------------------------------
module "route53" {
  source = "./modules/route53"
  count  = var.create_dns_resources ? 1 : 0

  project_name      = var.project_name
  aws_region        = var.aws_region
  environment       = var.environment
  cluster_name      = module.eks.cluster_name
  domain_name       = var.domain_name
  hosted_zone_id    = var.hosted_zone_id
  oidc_provider_arn = module.eks.oidc_provider_arn
  oidc_provider_url = module.eks.oidc_provider_url
  tags              = local.common_tags
}

# ------------------------------------------------------------------------------
# ArgoCD Module (EKS Add-on for GitOps)
# ------------------------------------------------------------------------------
# ArgoCD Module (Helm-based GitOps)
# ------------------------------------------------------------------------------
module "argocd" {
  source = "./modules/argocd"
  count  = var.enable_argocd ? 1 : 0

  chart_version          = var.argocd_addon_version
  enable_demo_app_sync   = var.argocd_enable_demo_app_sync
  git_repo_url           = var.argocd_git_repo_url
  git_target_revision    = var.argocd_git_target_revision
  git_manifests_path     = var.argocd_git_manifests_path
  auto_prune             = var.argocd_auto_prune
  auto_sync              = var.argocd_auto_sync

  depends_on = [module.eks]
}

# ------------------------------------------------------------------------------
# Metrics Server (required for HPA)
# ------------------------------------------------------------------------------
resource "helm_release" "metrics_server" {
  name       = "metrics-server"
  repository = "https://kubernetes-sigs.github.io/metrics-server/"
  chart      = "metrics-server"
  version    = "3.12.2"
  namespace  = "kube-system"

  set {
    name  = "replicas"
    value = "2"
  }

  depends_on = [module.eks]
}

# ------------------------------------------------------------------------------
# EBS CSI Driver (required for gp3 StorageClass & PVCs)
# ------------------------------------------------------------------------------
module "ebs_csi" {
  source = "./modules/ebs-csi"
  count  = var.enable_monitoring ? 1 : 0

  cluster_name      = module.eks.cluster_name
  oidc_provider_arn = module.eks.oidc_provider_arn
  oidc_provider_url = module.eks.oidc_provider_url
  ebs_kms_key_arn   = module.security.ebs_kms_key_arn
  chart_version     = var.ebs_csi_driver_version
  tags              = local.common_tags

  depends_on = [module.eks]
}

# ------------------------------------------------------------------------------
# Monitoring Storage (S3 buckets & IRSA roles for Loki + Tempo)
# ------------------------------------------------------------------------------
module "monitoring_storage" {
  source = "./modules/monitoring-storage"
  count  = var.enable_monitoring ? 1 : 0

  cluster_name         = module.eks.cluster_name
  oidc_provider_arn    = module.eks.oidc_provider_arn
  oidc_provider_url    = module.eks.oidc_provider_url
  loki_retention_days  = var.loki_retention_days
  tempo_retention_days = var.tempo_retention_days
  force_destroy        = var.monitoring_force_destroy
  tags                 = local.common_tags
}

# ------------------------------------------------------------------------------
# Monitoring Stack (Prometheus, Grafana, Loki, Promtail, Tempo)
# ------------------------------------------------------------------------------
module "monitoring_stack" {
  source = "./modules/monitoring-stack"
  count  = var.enable_monitoring ? 1 : 0

  cluster_name           = module.eks.cluster_name
  aws_region             = var.aws_region
  storage_class          = module.ebs_csi[0].storage_class_name
  grafana_admin_password = var.grafana_admin_password

  # Loki configuration
  loki_s3_bucket_name = module.monitoring_storage[0].loki_s3_bucket_name
  loki_iam_role_arn   = module.monitoring_storage[0].loki_iam_role_arn
  loki_retention_days = var.loki_retention_days

  # Tempo configuration
  tempo_s3_bucket_name = module.monitoring_storage[0].tempo_s3_bucket_name
  tempo_iam_role_arn   = module.monitoring_storage[0].tempo_iam_role_arn
  tempo_retention_days = var.tempo_retention_days

  # Chart versions
  prometheus_stack_version = var.prometheus_stack_version
  loki_version             = var.loki_version
  promtail_version         = var.promtail_version
  tempo_version            = var.tempo_version

  # Sizing
  prometheus_retention = var.prometheus_retention
  prometheus_pvc_size  = var.prometheus_pvc_size
  grafana_pvc_size     = var.grafana_pvc_size

  tags = local.common_tags

  depends_on = [
    module.ebs_csi,
    module.monitoring_storage
  ]
}
