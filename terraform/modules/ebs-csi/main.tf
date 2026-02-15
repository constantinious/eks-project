# ------------------------------------------------------------------------------
# EBS CSI Driver Module
# Deploys the AWS EBS CSI driver for persistent volume support.
# Uses IRSA for secure, least-privilege access to the EBS API.
# ------------------------------------------------------------------------------

data "aws_caller_identity" "current" {}
data "aws_partition" "current" {}

# ------------------------------------------------------------------------------
# IAM Role for EBS CSI Driver (IRSA)
# ------------------------------------------------------------------------------
resource "aws_iam_role" "ebs_csi" {
  name = "${var.cluster_name}-ebs-csi-driver"

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
            "${var.oidc_provider_url}:sub" = "system:serviceaccount:kube-system:ebs-csi-controller-sa"
          }
        }
      }
    ]
  })

  tags = var.tags
}

resource "aws_iam_role_policy_attachment" "ebs_csi" {
  policy_arn = "arn:${data.aws_partition.current.partition}:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
  role       = aws_iam_role.ebs_csi.name
}

# Allow EBS CSI to use KMS for encrypted volumes
resource "aws_iam_role_policy" "ebs_csi_kms" {
  name = "${var.cluster_name}-ebs-csi-kms"
  role = aws_iam_role.ebs_csi.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "kms:Decrypt",
          "kms:GenerateDataKeyWithoutPlaintext",
          "kms:CreateGrant"
        ]
        Resource = var.ebs_kms_key_arn
      }
    ]
  })
}

# ------------------------------------------------------------------------------
# EBS CSI Driver Helm Release
# ------------------------------------------------------------------------------
resource "helm_release" "ebs_csi_driver" {
  name       = "aws-ebs-csi-driver"
  repository = "https://kubernetes-sigs.github.io/aws-ebs-csi-driver"
  chart      = "aws-ebs-csi-driver"
  namespace  = "kube-system"
  version    = var.chart_version

  set {
    name  = "controller.serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
    value = aws_iam_role.ebs_csi.arn
  }

  set {
    name  = "controller.serviceAccount.name"
    value = "ebs-csi-controller-sa"
  }

  set {
    name  = "node.tolerateAllTaints"
    value = "true"
  }
}

# ------------------------------------------------------------------------------
# gp3 StorageClass (default for monitoring PVCs)
# ------------------------------------------------------------------------------
resource "kubernetes_storage_class_v1" "gp3" {
  metadata {
    name = "gp3"
    annotations = {
      "storageclass.kubernetes.io/is-default-class" = "true"
    }
  }

  storage_provisioner    = "ebs.csi.aws.com"
  reclaim_policy         = "Delete"
  allow_volume_expansion = true
  volume_binding_mode    = "WaitForFirstConsumer"

  parameters = {
    type      = "gp3"
    encrypted = "true"
    fsType    = "ext4"
    kmsKeyId  = var.ebs_kms_key_arn != "" ? var.ebs_kms_key_arn : ""
  }

  depends_on = [helm_release.ebs_csi_driver]
}

# Remove the default gp2 StorageClass annotation so gp3 becomes default
resource "kubernetes_annotations" "remove_gp2_default" {
  api_version = "storage.k8s.io/v1"
  kind        = "StorageClass"
  metadata {
    name = "gp2"
  }

  annotations = {
    "storageclass.kubernetes.io/is-default-class" = "false"
  }

  force = true

  depends_on = [kubernetes_storage_class_v1.gp3]
}
