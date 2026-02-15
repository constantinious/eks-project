# ------------------------------------------------------------------------------
# Route53 Module - Outputs
# ------------------------------------------------------------------------------

output "certificate_arn" {
  description = "ARN of the ACM wildcard certificate"
  value       = var.create_certificate ? aws_acm_certificate.wildcard[0].arn : ""
}

output "certificate_domain_name" {
  description = "Domain name of the ACM certificate"
  value       = var.create_certificate ? aws_acm_certificate.wildcard[0].domain_name : ""
}

output "external_dns_role_arn" {
  description = "ARN of the ExternalDNS IAM role"
  value       = aws_iam_role.external_dns.arn
}

output "external_dns_helm_release_name" {
  description = "Name of the ExternalDNS Helm release"
  value       = helm_release.external_dns.name
}
