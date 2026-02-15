# ------------------------------------------------------------------------------
# Monitoring Stack Module - Variables
# ------------------------------------------------------------------------------

variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
}

variable "aws_region" {
  description = "AWS region"
  type        = string
}

variable "storage_class" {
  description = "Kubernetes StorageClass for monitoring PVCs"
  type        = string
  default     = "gp3"
}

# --- Prometheus ---
variable "prometheus_stack_version" {
  description = "Version of the kube-prometheus-stack Helm chart"
  type        = string
  default     = "67.9.0"
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

# --- Grafana ---
variable "grafana_admin_password" {
  description = "Admin password for Grafana"
  type        = string
  sensitive   = true
}

variable "grafana_pvc_size" {
  description = "Grafana PVC size"
  type        = string
  default     = "10Gi"
}

# --- Loki ---
variable "loki_version" {
  description = "Version of the Loki Helm chart"
  type        = string
  default     = "6.24.0"
}

variable "loki_s3_bucket_name" {
  description = "S3 bucket name for Loki storage"
  type        = string
}

variable "loki_iam_role_arn" {
  description = "IAM role ARN for Loki IRSA"
  type        = string
}

variable "loki_retention_days" {
  description = "Number of days to retain logs in Loki"
  type        = number
  default     = 30
}

# --- Promtail ---
variable "promtail_version" {
  description = "Version of the Promtail Helm chart"
  type        = string
  default     = "6.16.6"
}

# --- Tempo ---
variable "tempo_version" {
  description = "Version of the Tempo Helm chart"
  type        = string
  default     = "1.14.0"
}

variable "tempo_s3_bucket_name" {
  description = "S3 bucket name for Tempo storage"
  type        = string
}

variable "tempo_iam_role_arn" {
  description = "IAM role ARN for Tempo IRSA"
  type        = string
}

variable "tempo_retention_days" {
  description = "Number of days to retain trace data"
  type        = number
  default     = 7
}

# --- Namespace Quotas ---
variable "namespace_cpu_request_quota" {
  description = "CPU request quota for monitoring namespace"
  type        = string
  default     = "8"
}

variable "namespace_memory_request_quota" {
  description = "Memory request quota for monitoring namespace"
  type        = string
  default     = "16Gi"
}

variable "namespace_cpu_limit_quota" {
  description = "CPU limit quota for monitoring namespace"
  type        = string
  default     = "16"
}

variable "namespace_memory_limit_quota" {
  description = "Memory limit quota for monitoring namespace"
  type        = string
  default     = "32Gi"
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default     = {}
}
