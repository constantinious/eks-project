# ------------------------------------------------------------------------------
# Security Module
# KMS keys for encryption at rest, security groups, and IAM baseline
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
# KMS Key for EKS Secrets Encryption
# ------------------------------------------------------------------------------
resource "aws_kms_key" "eks" {
  description             = "KMS key for EKS secrets encryption - ${var.project_name}-${var.environment}"
  deletion_window_in_days = 7
  enable_key_rotation     = true

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "Enable IAM User Permissions"
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
        }
        Action   = "kms:*"
        Resource = "*"
      },
      {
        Sid    = "Allow EKS to use the key"
        Effect = "Allow"
        Principal = {
          Service = "eks.amazonaws.com"
        }
        Action = [
          "kms:Encrypt",
          "kms:Decrypt",
          "kms:ReEncrypt*",
          "kms:GenerateDataKey*",
          "kms:DescribeKey",
          "kms:CreateGrant"
        ]
        Resource = "*"
      }
    ]
  })

  tags = merge(var.tags, {
    Name = "${var.project_name}-${var.environment}-eks-kms"
  })
}

resource "aws_kms_alias" "eks" {
  name          = "alias/${var.project_name}-${var.environment}-eks"
  target_key_id = aws_kms_key.eks.key_id
}

# ------------------------------------------------------------------------------
# KMS Key for EBS Volume Encryption
# ------------------------------------------------------------------------------
resource "aws_kms_key" "ebs" {
  description             = "KMS key for EBS encryption - ${var.project_name}-${var.environment}"
  deletion_window_in_days = 7
  enable_key_rotation     = true

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "Enable IAM User Permissions"
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
        }
        Action   = "kms:*"
        Resource = "*"
      },
      {
        Sid    = "Allow Auto Scaling service-linked role to use the key"
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/aws-service-role/autoscaling.amazonaws.com/AWSServiceRoleForAutoScaling"
        }
        Action = [
          "kms:Encrypt",
          "kms:Decrypt",
          "kms:ReEncrypt*",
          "kms:GenerateDataKey*",
          "kms:DescribeKey",
          "kms:CreateGrant"
        ]
        Resource = "*"
      },
      {
        Sid    = "Allow EKS node roles to use the key for EBS"
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
        }
        Action = [
          "kms:Encrypt",
          "kms:Decrypt",
          "kms:ReEncrypt*",
          "kms:GenerateDataKey*",
          "kms:DescribeKey",
          "kms:CreateGrant"
        ]
        Resource = "*"
        Condition = {
          StringLike = {
            "kms:ViaService" = "ec2.*.amazonaws.com"
          }
        }
      }
    ]
  })

  tags = merge(var.tags, {
    Name = "${var.project_name}-${var.environment}-ebs-kms"
  })
}

resource "aws_kms_alias" "ebs" {
  name          = "alias/${var.project_name}-${var.environment}-ebs"
  target_key_id = aws_kms_key.ebs.key_id
}

# ------------------------------------------------------------------------------
# EKS Cluster Security Group
# Controls traffic to/from the EKS control plane
# ------------------------------------------------------------------------------
resource "aws_security_group" "eks_cluster" {
  name_prefix = "${var.project_name}-${var.environment}-eks-cluster-"
  description = "Security group for EKS cluster control plane"
  vpc_id      = var.vpc_id

  tags = merge(var.tags, {
    Name = "${var.project_name}-${var.environment}-eks-cluster-sg"
  })

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_vpc_security_group_ingress_rule" "eks_cluster_https" {
  security_group_id = aws_security_group.eks_cluster.id
  description       = "Allow HTTPS from worker nodes"

  referenced_security_group_id = aws_security_group.eks_nodes.id
  from_port                    = 443
  to_port                      = 443
  ip_protocol                  = "tcp"
}

resource "aws_vpc_security_group_egress_rule" "eks_cluster_all" {
  security_group_id = aws_security_group.eks_cluster.id
  description       = "Allow all outbound traffic"

  cidr_ipv4   = "0.0.0.0/0"
  ip_protocol = "-1"
}

# ------------------------------------------------------------------------------
# EKS Worker Nodes Security Group
# Controls traffic to/from the EKS worker nodes
# ------------------------------------------------------------------------------
resource "aws_security_group" "eks_nodes" {
  name_prefix = "${var.project_name}-${var.environment}-eks-nodes-"
  description = "Security group for EKS worker nodes"
  vpc_id      = var.vpc_id

  tags = merge(var.tags, {
    Name                                        = "${var.project_name}-${var.environment}-eks-nodes-sg"
    "kubernetes.io/cluster/${var.cluster_name}" = "owned"
  })

  lifecycle {
    create_before_destroy = true
  }
}

# Node-to-node communication
resource "aws_vpc_security_group_ingress_rule" "eks_nodes_self" {
  security_group_id = aws_security_group.eks_nodes.id
  description       = "Allow node-to-node communication"

  referenced_security_group_id = aws_security_group.eks_nodes.id
  ip_protocol                  = "-1"
}

# Control plane to nodes
resource "aws_vpc_security_group_ingress_rule" "eks_nodes_cluster" {
  security_group_id = aws_security_group.eks_nodes.id
  description       = "Allow control plane to communicate with nodes"

  referenced_security_group_id = aws_security_group.eks_cluster.id
  from_port                    = 1025
  to_port                      = 65535
  ip_protocol                  = "tcp"
}

# Control plane to nodes (443 for webhook)
resource "aws_vpc_security_group_ingress_rule" "eks_nodes_cluster_https" {
  security_group_id = aws_security_group.eks_nodes.id
  description       = "Allow control plane to communicate with nodes on 443"

  referenced_security_group_id = aws_security_group.eks_cluster.id
  from_port                    = 443
  to_port                      = 443
  ip_protocol                  = "tcp"
}

resource "aws_vpc_security_group_egress_rule" "eks_nodes_all" {
  security_group_id = aws_security_group.eks_nodes.id
  description       = "Allow all outbound traffic"

  cidr_ipv4   = "0.0.0.0/0"
  ip_protocol = "-1"
}

# ------------------------------------------------------------------------------
# Data Sources
# ------------------------------------------------------------------------------
data "aws_caller_identity" "current" {}
