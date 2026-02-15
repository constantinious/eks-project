# ------------------------------------------------------------------------------
# Monitoring Storage Module - Outputs
# ------------------------------------------------------------------------------

output "loki_s3_bucket_name" {
  description = "Name of the Loki S3 bucket"
  value       = aws_s3_bucket.loki.id
}

output "loki_s3_bucket_arn" {
  description = "ARN of the Loki S3 bucket"
  value       = aws_s3_bucket.loki.arn
}

output "loki_iam_role_arn" {
  description = "ARN of the Loki IRSA role"
  value       = aws_iam_role.loki.arn
}

output "tempo_s3_bucket_name" {
  description = "Name of the Tempo S3 bucket"
  value       = aws_s3_bucket.tempo.id
}

output "tempo_s3_bucket_arn" {
  description = "ARN of the Tempo S3 bucket"
  value       = aws_s3_bucket.tempo.arn
}

output "tempo_iam_role_arn" {
  description = "ARN of the Tempo IRSA role"
  value       = aws_iam_role.tempo.arn
}
