# ------------------------------------------------------------------------------
# Monitoring Storage Module
# S3 buckets for Loki (logs) and Tempo (traces) long-term storage,
# with IRSA roles for secure, least-privilege access.
# ------------------------------------------------------------------------------

data "aws_caller_identity" "current" {}
data "aws_partition" "current" {}

# ------------------------------------------------------------------------------
# Loki S3 Bucket (log chunks + index)
# ------------------------------------------------------------------------------
resource "aws_s3_bucket" "loki" {
  bucket        = lower("${var.cluster_name}-loki-${data.aws_caller_identity.current.account_id}")
  force_destroy = var.force_destroy

  tags = merge(var.tags, {
    Name      = "${var.cluster_name}-loki"
    Component = "monitoring"
  })
}

resource "aws_s3_bucket_versioning" "loki" {
  bucket = aws_s3_bucket.loki.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "loki" {
  bucket = aws_s3_bucket.loki.id

  rule {
    id     = "expire-old-logs"
    status = "Enabled"

    expiration {
      days = var.loki_retention_days
    }

    noncurrent_version_expiration {
      noncurrent_days = 7
    }
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "loki" {
  bucket = aws_s3_bucket.loki.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "aws:kms"
    }
    bucket_key_enabled = true
  }
}

resource "aws_s3_bucket_public_access_block" "loki" {
  bucket                  = aws_s3_bucket.loki.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# ------------------------------------------------------------------------------
# Tempo S3 Bucket (trace data)
# ------------------------------------------------------------------------------
resource "aws_s3_bucket" "tempo" {
  bucket        = lower("${var.cluster_name}-tempo-${data.aws_caller_identity.current.account_id}")
  force_destroy = var.force_destroy

  tags = merge(var.tags, {
    Name      = "${var.cluster_name}-tempo"
    Component = "monitoring"
  })
}

resource "aws_s3_bucket_versioning" "tempo" {
  bucket = aws_s3_bucket.tempo.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "tempo" {
  bucket = aws_s3_bucket.tempo.id

  rule {
    id     = "expire-old-traces"
    status = "Enabled"

    expiration {
      days = var.tempo_retention_days
    }

    noncurrent_version_expiration {
      noncurrent_days = 7
    }
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "tempo" {
  bucket = aws_s3_bucket.tempo.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "aws:kms"
    }
    bucket_key_enabled = true
  }
}

resource "aws_s3_bucket_public_access_block" "tempo" {
  bucket                  = aws_s3_bucket.tempo.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# ------------------------------------------------------------------------------
# IAM Role for Loki (IRSA)
# ------------------------------------------------------------------------------
resource "aws_iam_role" "loki" {
  name = "${var.cluster_name}-loki"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Federated = var.oidc_provider_arn
        }
        Action = "sts:AssumeRoleWithWebIdentity"
        Condition = {
          StringEquals = {
            "${var.oidc_provider_url}:aud" = "sts.amazonaws.com"
            "${var.oidc_provider_url}:sub" = "system:serviceaccount:monitoring:loki"
          }
        }
      }
    ]
  })

  tags = var.tags
}

resource "aws_iam_role_policy" "loki_s3" {
  name = "${var.cluster_name}-loki-s3"
  role = aws_iam_role.loki.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:PutObject",
          "s3:GetObject",
          "s3:DeleteObject",
          "s3:ListBucket"
        ]
        Resource = [
          aws_s3_bucket.loki.arn,
          "${aws_s3_bucket.loki.arn}/*"
        ]
      }
    ]
  })
}

# ------------------------------------------------------------------------------
# IAM Role for Tempo (IRSA)
# ------------------------------------------------------------------------------
resource "aws_iam_role" "tempo" {
  name = "${var.cluster_name}-tempo"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Federated = var.oidc_provider_arn
        }
        Action = "sts:AssumeRoleWithWebIdentity"
        Condition = {
          StringEquals = {
            "${var.oidc_provider_url}:aud" = "sts.amazonaws.com"
            "${var.oidc_provider_url}:sub" = "system:serviceaccount:monitoring:tempo"
          }
        }
      }
    ]
  })

  tags = var.tags
}

resource "aws_iam_role_policy" "tempo_s3" {
  name = "${var.cluster_name}-tempo-s3"
  role = aws_iam_role.tempo.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:PutObject",
          "s3:GetObject",
          "s3:DeleteObject",
          "s3:ListBucket"
        ]
        Resource = [
          aws_s3_bucket.tempo.arn,
          "${aws_s3_bucket.tempo.arn}/*"
        ]
      }
    ]
  })
}
