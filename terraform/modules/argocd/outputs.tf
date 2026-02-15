output "addon_arn" {
  description = "ARN of the ArgoCD EKS add-on"
  value       = aws_eks_addon.argocd.arn
}

output "addon_version" {
  description = "Version of the ArgoCD add-on"
  value       = aws_eks_addon.argocd.addon_version
}

output "argocd_namespace" {
  description = "Namespace where ArgoCD is deployed"
  value       = kubernetes_namespace.argocd.metadata[0].name
}

output "argocd_server_service" {
  description = "Command to access ArgoCD UI via port-forward"
  value       = "kubectl port-forward svc/argo-cd-argocd-server -n argocd 8080:443"
}
