# ------------------------------------------------------------------------------
# ALB Controller Module - Outputs
# ------------------------------------------------------------------------------

output "iam_role_arn" {
  description = "ARN of the ALB Controller IAM role"
  value       = aws_iam_role.alb_controller.arn
}

output "iam_policy_arn" {
  description = "ARN of the ALB Controller IAM policy"
  value       = aws_iam_policy.alb_controller.arn
}

output "helm_release_name" {
  description = "Name of the Helm release"
  value       = helm_release.alb_controller.name
}

output "helm_release_version" {
  description = "Version of the Helm chart deployed"
  value       = helm_release.alb_controller.version
}
