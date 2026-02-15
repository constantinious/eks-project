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

# Note: The ArgoCD Application manifest for demo-app will be created
# separately using kubectl after the cluster and ArgoCD are ready.
# See: kubernetes/argocd/application.yaml
