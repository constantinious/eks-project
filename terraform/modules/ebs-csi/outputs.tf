# ------------------------------------------------------------------------------
# EBS CSI Driver Module - Outputs
# ------------------------------------------------------------------------------

output "iam_role_arn" {
  description = "ARN of the EBS CSI Driver IAM role"
  value       = aws_iam_role.ebs_csi.arn
}

output "storage_class_name" {
  description = "Name of the gp3 StorageClass"
  value       = kubernetes_storage_class_v1.gp3.metadata[0].name
}
