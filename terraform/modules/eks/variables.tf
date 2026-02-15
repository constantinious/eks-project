# ------------------------------------------------------------------------------
# EKS Module - Variables
# ------------------------------------------------------------------------------

variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
}

variable "cluster_version" {
  description = "Kubernetes version for the EKS cluster"
  type        = string
  default     = "1.29"
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "private_subnet_ids" {
  description = "IDs of private subnets for the EKS cluster"
  type        = list(string)
}

variable "public_subnet_ids" {
  description = "IDs of public subnets for the EKS cluster"
  type        = list(string)
}

variable "cluster_security_group_id" {
  description = "Security group ID for the EKS cluster"
  type        = string
}

variable "node_security_group_id" {
  description = "Security group ID for EKS worker nodes"
  type        = string
}

variable "kms_key_arn" {
  description = "ARN of KMS key for EKS secrets encryption"
  type        = string
}

variable "ebs_kms_key_arn" {
  description = "ARN of KMS key for EBS volume encryption"
  type        = string
}

variable "cluster_endpoint_private_access" {
  description = "Enable private access to the EKS API server"
  type        = bool
  default     = true
}

variable "cluster_endpoint_public_access" {
  description = "Enable public access to the EKS API server"
  type        = bool
  default     = true
}

variable "cluster_endpoint_public_access_cidrs" {
  description = "CIDR blocks allowed to access the EKS API server"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "ami_type" {
  description = "AMI type for EKS nodes. Use AL2_ARM_64 for Graviton (t4g/m6g), AL2_x86_64 for x86"
  type        = string
  default     = "AL2_ARM_64"
}

variable "node_instance_types" {
  description = "Instance types for the managed node group"
  type        = list(string)
  default     = ["t4g.small"]
}

variable "node_min_size" {
  description = "Minimum number of nodes"
  type        = number
  default     = 2
}

variable "node_max_size" {
  description = "Maximum number of nodes"
  type        = number
  default     = 10
}

variable "node_desired_size" {
  description = "Desired number of nodes"
  type        = number
  default     = 3
}

variable "node_disk_size" {
  description = "Disk size in GiB for worker nodes"
  type        = number
  default     = 50
}

variable "enable_cluster_autoscaler" {
  description = "Enable Cluster Autoscaler IRSA role"
  type        = bool
  default     = true
}

variable "enabled_cluster_log_types" {
  description = "EKS control plane log types to enable"
  type        = list(string)
  default     = ["api", "audit"] # Minimal set for cost optimization
}

variable "log_retention_days" {
  description = "Retention period for EKS control plane logs (days)"
  type        = number
  default     = 7 # Reduced for cost optimization
}

variable "additional_admin_arns" {
  description = "List of IAM user/role ARNs to grant cluster admin access"
  type        = list(string)
  default     = []
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default     = {}
}
