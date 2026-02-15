# ------------------------------------------------------------------------------
# Route53 Module - Variables
# ------------------------------------------------------------------------------

variable "project_name" {
  description = "Name of the project"
  type        = string
}

variable "aws_region" {
  description = "AWS region"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
}

variable "domain_name" {
  description = "Domain name (e.g., example.com)"
  type        = string
}

variable "hosted_zone_id" {
  description = "Route53 hosted zone ID"
  type        = string
}

variable "oidc_provider_arn" {
  description = "ARN of the OIDC provider"
  type        = string
}

variable "oidc_provider_url" {
  description = "URL of the OIDC provider (without https://)"
  type        = string
}

variable "create_certificate" {
  description = "Whether to create an ACM wildcard certificate"
  type        = bool
  default     = true
}

variable "external_dns_chart_version" {
  description = "Version of the ExternalDNS Helm chart"
  type        = string
  default     = "1.15.0"
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default     = {}
}
