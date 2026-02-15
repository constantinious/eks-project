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
  node_instance_types                  = var.node_instance_types
  node_min_size                        = var.node_min_size
  node_max_size                        = var.node_max_size
  node_desired_size                    = var.node_desired_size
  node_disk_size                       = var.node_disk_size
  enable_cluster_autoscaler            = var.enable_cluster_autoscaler
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
