# ------------------------------------------------------------------------------
# Monitoring Stack Module - Outputs
# ------------------------------------------------------------------------------

output "monitoring_namespace" {
  description = "Name of the monitoring namespace"
  value       = kubernetes_namespace_v1.monitoring.metadata[0].name
}

output "grafana_service_name" {
  description = "Grafana Kubernetes service name"
  value       = "kube-prometheus-stack-grafana"
}

output "prometheus_service_name" {
  description = "Prometheus Kubernetes service name"
  value       = "kube-prometheus-stack-prometheus"
}

output "loki_service_name" {
  description = "Loki Kubernetes service name"
  value       = "loki"
}

output "tempo_service_name" {
  description = "Tempo Kubernetes service name"
  value       = "tempo"
}

output "grafana_port_forward_command" {
  description = "Command to port-forward Grafana for local access"
  value       = "kubectl port-forward -n monitoring svc/kube-prometheus-stack-grafana 3000:80"
}

output "prometheus_port_forward_command" {
  description = "Command to port-forward Prometheus for local access"
  value       = "kubectl port-forward -n monitoring svc/kube-prometheus-stack-prometheus 9090:9090"
}
