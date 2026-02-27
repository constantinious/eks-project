# ------------------------------------------------------------------------------
# Monitoring Stack Module
# Deploys the full observability stack: Prometheus, Grafana, AlertManager,
# Loki, Promtail, and Tempo into a dedicated monitoring namespace.
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
# Monitoring Namespace
# ------------------------------------------------------------------------------
resource "kubernetes_namespace_v1" "monitoring" {
  metadata {
    name = "monitoring"

    labels = {
      "app.kubernetes.io/managed-by"               = "terraform"
      "pod-security.kubernetes.io/enforce"         = "privileged"
      "pod-security.kubernetes.io/enforce-version" = "latest"
    }
  }
}

# ------------------------------------------------------------------------------
# Resource Quota for Monitoring Namespace
# ------------------------------------------------------------------------------
resource "kubernetes_resource_quota_v1" "monitoring" {
  metadata {
    name      = "monitoring-quota"
    namespace = kubernetes_namespace_v1.monitoring.metadata[0].name
  }

  spec {
    hard = {
      "requests.cpu"           = var.namespace_cpu_request_quota
      "requests.memory"        = var.namespace_memory_request_quota
      "limits.cpu"             = var.namespace_cpu_limit_quota
      "limits.memory"          = var.namespace_memory_limit_quota
      "persistentvolumeclaims" = "20"
    }
  }
}

# ------------------------------------------------------------------------------
# Limit Range for Monitoring Namespace
# ------------------------------------------------------------------------------
resource "kubernetes_limit_range_v1" "monitoring" {
  metadata {
    name      = "monitoring-limits"
    namespace = kubernetes_namespace_v1.monitoring.metadata[0].name
  }

  spec {
    limit {
      type = "Container"
      default = {
        cpu    = "500m"
        memory = "512Mi"
      }
      default_request = {
        cpu    = "100m"
        memory = "128Mi"
      }
    }
  }
}

# ------------------------------------------------------------------------------
# kube-prometheus-stack (Prometheus, Grafana, AlertManager)
# ------------------------------------------------------------------------------
resource "helm_release" "kube_prometheus_stack" {
  name       = "kube-prometheus-stack"
  repository = "https://prometheus-community.github.io/helm-charts"
  chart      = "kube-prometheus-stack"
  namespace  = kubernetes_namespace_v1.monitoring.metadata[0].name
  version    = var.prometheus_stack_version

  values = [templatefile("${path.module}/values/prometheus-stack-values.yaml", {
    grafana_admin_password = var.grafana_admin_password
    storage_class          = var.storage_class
    prometheus_retention   = var.prometheus_retention
    prometheus_pvc_size    = var.prometheus_pvc_size
    grafana_pvc_size       = var.grafana_pvc_size
    loki_url               = "http://loki:3100"
    tempo_url              = "http://tempo:3100"
  })]

  timeout = 600

  depends_on = [kubernetes_namespace_v1.monitoring]
}

# ------------------------------------------------------------------------------
# Loki (Log Aggregation)
# ------------------------------------------------------------------------------
resource "helm_release" "loki" {
  name       = "loki"
  repository = "https://grafana.github.io/helm-charts"
  chart      = "loki"
  namespace  = kubernetes_namespace_v1.monitoring.metadata[0].name
  version    = var.loki_version

  values = [templatefile("${path.module}/values/loki-values.yaml", {
    s3_bucket_name   = var.loki_s3_bucket_name
    s3_bucket_region = var.aws_region
    iam_role_arn     = var.loki_iam_role_arn
    retention_days   = var.loki_retention_days
    storage_class    = var.storage_class
  })]

  timeout = 600

  depends_on = [kubernetes_namespace_v1.monitoring]
}

# ------------------------------------------------------------------------------
# Promtail (Log Collection Agent - DaemonSet)
# ------------------------------------------------------------------------------
resource "helm_release" "promtail" {
  name       = "promtail"
  repository = "https://grafana.github.io/helm-charts"
  chart      = "promtail"
  namespace  = kubernetes_namespace_v1.monitoring.metadata[0].name
  version    = var.promtail_version

  values = [templatefile("${path.module}/values/promtail-values.yaml", {
    loki_url = "http://loki-gateway.monitoring.svc.cluster.local"
  })]

  timeout = 300

  depends_on = [helm_release.loki]
}

# ------------------------------------------------------------------------------
# Tempo (Distributed Tracing)
# ------------------------------------------------------------------------------
resource "helm_release" "tempo" {
  name       = "tempo"
  repository = "https://grafana.github.io/helm-charts"
  chart      = "tempo"
  namespace  = kubernetes_namespace_v1.monitoring.metadata[0].name
  version    = var.tempo_version

  values = [templatefile("${path.module}/values/tempo-values.yaml", {
    s3_bucket_name   = var.tempo_s3_bucket_name
    s3_bucket_region = var.aws_region
    iam_role_arn     = var.tempo_iam_role_arn
    retention_hours  = var.tempo_retention_days * 24
    storage_class    = var.storage_class
  })]

  timeout = 300

  depends_on = [kubernetes_namespace_v1.monitoring]
}

# ------------------------------------------------------------------------------
# Network Policy - Default Deny Ingress
# ------------------------------------------------------------------------------
resource "kubernetes_network_policy_v1" "monitoring_default_deny" {
  metadata {
    name      = "default-deny-ingress"
    namespace = kubernetes_namespace_v1.monitoring.metadata[0].name
  }

  spec {
    pod_selector {}
    policy_types = ["Ingress"]
  }
}

# ------------------------------------------------------------------------------
# Network Policy - Allow intra-namespace traffic
# ------------------------------------------------------------------------------
resource "kubernetes_network_policy_v1" "monitoring_allow_internal" {
  metadata {
    name      = "allow-monitoring-internal"
    namespace = kubernetes_namespace_v1.monitoring.metadata[0].name
  }

  spec {
    pod_selector {}

    ingress {
      from {
        namespace_selector {
          match_labels = {
            "kubernetes.io/metadata.name" = "monitoring"
          }
        }
      }
    }

    policy_types = ["Ingress"]
  }
}

# ------------------------------------------------------------------------------
# Network Policy - Allow Prometheus to scrape all namespaces
# ------------------------------------------------------------------------------
resource "kubernetes_network_policy_v1" "allow_prometheus_scrape" {
  metadata {
    name      = "allow-prometheus-scrape"
    namespace = kubernetes_namespace_v1.monitoring.metadata[0].name
  }

  spec {
    pod_selector {
      match_labels = {
        "app.kubernetes.io/name" = "prometheus"
      }
    }

    egress {
      ports {
        port     = "9090"
        protocol = "TCP"
      }
      ports {
        port     = "9100"
        protocol = "TCP"
      }
      ports {
        port     = "10250"
        protocol = "TCP"
      }
      # Allow DNS
      ports {
        port     = "53"
        protocol = "UDP"
      }
      ports {
        port     = "53"
        protocol = "TCP"
      }
      # Allow HTTPS (Kubernetes API)
      ports {
        port     = "443"
        protocol = "TCP"
      }
    }

    policy_types = ["Egress"]
  }
}

# ------------------------------------------------------------------------------
# Network Policy - Allow Promtail to send logs to Loki
# Promtail runs as DaemonSet in monitoring namespace
# ------------------------------------------------------------------------------
resource "kubernetes_network_policy_v1" "allow_promtail_to_loki" {
  metadata {
    name      = "allow-promtail-to-loki"
    namespace = kubernetes_namespace_v1.monitoring.metadata[0].name
  }

  spec {
    pod_selector {
      match_labels = {
        "app.kubernetes.io/name" = "loki"
      }
    }

    ingress {
      from {
        pod_selector {
          match_labels = {
            "app.kubernetes.io/name" = "promtail"
          }
        }
      }
      ports {
        port     = "3100"
        protocol = "TCP"
      }
    }

    policy_types = ["Ingress"]
  }
}

# ------------------------------------------------------------------------------
# Network Policy - Allow Grafana to be accessed (for port-forward / ALB)
# ------------------------------------------------------------------------------
resource "kubernetes_network_policy_v1" "allow_grafana_ingress" {
  metadata {
    name      = "allow-grafana-ingress"
    namespace = kubernetes_namespace_v1.monitoring.metadata[0].name
  }

  spec {
    pod_selector {
      match_labels = {
        "app.kubernetes.io/name" = "grafana"
      }
    }

    ingress {
      ports {
        port     = "3000"
        protocol = "TCP"
      }
    }

    policy_types = ["Ingress"]
  }
}
