# ------------------------------------------------------------------------------
# EBS CSI Driver Module - Variables
# ------------------------------------------------------------------------------

variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
}

variable "oidc_provider_arn" {
  description = "ARN of the EKS cluster OIDC provider"
  type        = string
}

variable "oidc_provider_url" {
  description = "URL of the OIDC provider (without https://)"
  type        = string
}

variable "ebs_kms_key_arn" {
  description = "ARN of the KMS key for EBS encryption"
  type        = string
  default     = ""
}

variable "chart_version" {
  description = "Version of the aws-ebs-csi-driver Helm chart"
  type        = string
  default     = "2.37.0"
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default     = {}
}
