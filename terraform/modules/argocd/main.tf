resource "aws_eks_addon" "argocd" {
  cluster_name             = var.cluster_name
  addon_name               = "argo-cd"
  addon_version            = var.addon_version
  resolve_conflicts_on_create = "OVERWRITE"
  resolve_conflicts_on_update = "PRESERVE"

  tags = merge(
    var.tags,
    {
      Name = "${var.cluster_name}-argocd-addon"
    }
  )
}

# Create namespace for ArgoCD applications
resource "kubernetes_namespace" "argocd" {
  metadata {
    name = "argocd"
    labels = {
      "app.kubernetes.io/name"    = "argocd"
      "app.kubernetes.io/part-of" = "argocd"
    }
  }

  depends_on = [aws_eks_addon.argocd]
}

# ArgoCD Application to sync the demo app manifests from Git
resource "kubernetes_manifest" "demo_app_application" {
  count = var.enable_demo_app_sync ? 1 : 0

  manifest = {
    apiVersion = "argoproj.io/v1alpha1"
    kind       = "Application"
    metadata = {
      name      = "demo-app"
      namespace = "argocd"
    }
    spec = {
      project = "default"
      source = {
        repoURL        = var.git_repo_url
        targetRevision = var.git_target_revision
        path           = var.git_manifests_path
      }
      destination = {
        server    = "https://kubernetes.default.svc"
        namespace = "demo-app"
      }
      syncPolicy = {
        automated = {
          prune    = var.auto_prune
          selfHeal = var.auto_sync
        }
        syncOptions = [
          "CreateNamespace=true"
        ]
      }
    }
  }

  depends_on = [
    aws_eks_addon.argocd,
    kubernetes_namespace.argocd
  ]
}
