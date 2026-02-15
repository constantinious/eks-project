output "chart_version" {
  description = "ArgoCD Helm chart version deployed"
  value       = helm_release.argocd.version
}

output "argocd_namespace" {
  description = "Namespace where ArgoCD is deployed"
  value       = helm_release.argocd.namespace
}

output "argocd_server_service" {
  description = "Command to access ArgoCD UI via port-forward"
  value       = "kubectl port-forward svc/argo-cd-argocd-server -n argocd 8080:443"
}
