resource "helm_release" "argocd" {
  name             = "argo-cd"
  repository       = "https://argoproj.github.io/argo-helm"
  chart            = "argo-cd"
  version          = var.chart_version
  namespace        = "argocd"
  create_namespace = true

  # Server configuration
  set {
    name  = "server.service.type"
    value = "ClusterIP"
  }

  # Disable HA for cost optimization (single replica)
  set {
    name  = "controller.replicas"
    value = "1"
  }

  set {
    name  = "server.replicas"
    value = "1"
  }

  set {
    name  = "repoServer.replicas"
    value = "1"
  }

  set {
    name  = "applicationSet.replicas"
    value = "1"
  }

  # Disable unused components for minimal footprint
  set {
    name  = "dex.enabled"
    value = "false"
  }

  set {
    name  = "notifications.enabled"
    value = "false"
  }
}

# Note: The ArgoCD Application manifest for demo-app will be created
# separately using kubectl after the cluster and ArgoCD are ready.
# See: kubernetes/argocd/application.yaml
