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
  value       = "argocd"
}

output "argocd_server_service" {
  description = "Command to access ArgoCD UI via port-forward"
  value       = "kubectl port-forward svc/argo-cd-argocd-server -n argocd 8080:443"
}

output "setup_instructions" {
  description = "Instructions to complete ArgoCD setup"
  value       = <<-EOT
    ArgoCD EKS add-on has been deployed. To complete setup:
    
    1. Update kubeconfig:
       aws eks update-kubeconfig --name ${var.cluster_name} --region <your-region>
    
    2. Wait for ArgoCD to be ready:
       kubectl wait --for=condition=ready pod -l app.kubernetes.io/name=argocd-server -n argocd --timeout=300s
    
    3. Get admin password:
       kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath='{.data.password}' | base64 -d
    
    4. Access ArgoCD UI:
       kubectl port-forward svc/argo-cd-argocd-server -n argocd 8080:443
       Then open: https://localhost:8080 (username: admin)
    
    5. Deploy the demo-app Application:
       kubectl apply -f kubernetes/argocd/application.yaml
    
    After step 5, ArgoCD will automatically sync kubernetes/manifests/ from the main branch!
  EOT
}
