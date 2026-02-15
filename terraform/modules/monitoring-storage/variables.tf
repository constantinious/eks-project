# ------------------------------------------------------------------------------
# Monitoring Storage Module - Variables
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

variable "loki_retention_days" {
  description = "Number of days to retain Loki log data in S3"
  type        = number
  default     = 30
}

variable "tempo_retention_days" {
  description = "Number of days to retain Tempo trace data in S3"
  type        = number
  default     = 7
}

variable "force_destroy" {
  description = "Allow force destroy of S3 buckets (useful for dev environments)"
  type        = bool
  default     = false
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default     = {}
}
