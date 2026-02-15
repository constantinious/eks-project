# ------------------------------------------------------------------------------
# Root Outputs
# Important values for cluster access, application deployment, and integration.
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
# VPC
# ------------------------------------------------------------------------------
output "vpc_id" {
  description = "ID of the VPC"
  value       = module.vpc.vpc_id
}

output "vpc_cidr_block" {
  description = "CIDR block of the VPC"
  value       = module.vpc.vpc_cidr_block
}

output "private_subnet_ids" {
  description = "IDs of the private subnets"
  value       = module.vpc.private_subnet_ids
}

output "public_subnet_ids" {
  description = "IDs of the public subnets"
  value       = module.vpc.public_subnet_ids
}

# ------------------------------------------------------------------------------
# EKS Cluster
# ------------------------------------------------------------------------------
output "cluster_name" {
  description = "Name of the EKS cluster"
  value       = module.eks.cluster_name
}

output "cluster_endpoint" {
  description = "Endpoint for the EKS cluster API server"
  value       = module.eks.cluster_endpoint
}

output "cluster_version" {
  description = "Kubernetes version of the EKS cluster"
  value       = module.eks.cluster_version
}

output "cluster_certificate_authority_data" {
  description = "Base64 encoded certificate data for the cluster"
  value       = module.eks.cluster_certificate_authority_data
  sensitive   = true
}

output "cluster_oidc_issuer_url" {
  description = "OIDC issuer URL for the EKS cluster"
  value       = module.eks.cluster_oidc_issuer_url
}

# ------------------------------------------------------------------------------
# Security
# ------------------------------------------------------------------------------
output "eks_kms_key_arn" {
  description = "ARN of the KMS key used for EKS secrets encryption"
  value       = module.security.eks_kms_key_arn
}

# ------------------------------------------------------------------------------
# ALB Controller
# ------------------------------------------------------------------------------
output "alb_controller_role_arn" {
  description = "ARN of the ALB Controller IAM role"
  value       = module.alb_controller.iam_role_arn
}

# ------------------------------------------------------------------------------
# DNS & TLS (conditional)
# ------------------------------------------------------------------------------
output "certificate_arn" {
  description = "ARN of the ACM wildcard certificate"
  value       = var.create_dns_resources ? module.route53[0].certificate_arn : "N/A - DNS resources not created"
}

output "external_dns_role_arn" {
  description = "ARN of the ExternalDNS IAM role"
  value       = var.create_dns_resources ? module.route53[0].external_dns_role_arn : "N/A - DNS resources not created"
}

# ------------------------------------------------------------------------------
# Cluster Autoscaler
# ------------------------------------------------------------------------------
output "cluster_autoscaler_role_arn" {
  description = "ARN of the Cluster Autoscaler IRSA role"
  value       = module.eks.cluster_autoscaler_role_arn
}

# ------------------------------------------------------------------------------
# Convenience
# ------------------------------------------------------------------------------
output "configure_kubectl" {
  description = "Command to configure kubectl for the cluster"
  value       = "aws eks update-kubeconfig --name ${module.eks.cluster_name} --region ${var.aws_region}"
}
