# ------------------------------------------------------------------------------
# Security Module - Outputs
# ------------------------------------------------------------------------------

output "eks_kms_key_arn" {
  description = "ARN of the KMS key for EKS secrets encryption"
  value       = aws_kms_key.eks.arn
}

output "eks_kms_key_id" {
  description = "ID of the KMS key for EKS secrets encryption"
  value       = aws_kms_key.eks.key_id
}

output "ebs_kms_key_arn" {
  description = "ARN of the KMS key for EBS volume encryption"
  value       = aws_kms_key.ebs.arn
}

output "ebs_kms_key_id" {
  description = "ID of the KMS key for EBS volume encryption"
  value       = aws_kms_key.ebs.key_id
}

output "eks_cluster_security_group_id" {
  description = "ID of the EKS cluster security group"
  value       = aws_security_group.eks_cluster.id
}

output "eks_nodes_security_group_id" {
  description = "ID of the EKS worker nodes security group"
  value       = aws_security_group.eks_nodes.id
}
