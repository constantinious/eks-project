# Portfolio Project Notice

## ⚠️ Important: Sanitized for Public Display

This repository has been prepared for portfolio demonstration. Sensitive information has been redacted:

- ✅ AWS Account IDs replaced with placeholders
- ✅ Real domain names replaced with examples  
- ✅ IAM user ARNs removed
- ✅ All secrets managed via environment variables
- ✅ State files and kubeconfig excluded via .gitignore

## What This Project Demonstrates

### Infrastructure as Code (Terraform)
- Modular architecture with reusable components
- AWS provider configuration with default tags
- Remote state management in S3

### AWS EKS Best Practices
- Multi-AZ deployment for high availability
- Private node groups with NAT Gateway
- KMS encryption at rest
- IRSA for pod-level IAM permissions
- Cluster autoscaling support

### Observability Stack
- Prometheus for metrics collection
- Grafana for visualization
- Loki for log aggregation
- Tempo for distributed tracing
- Promtail for log shipping

### GitOps with ArgoCD
- Declarative application deployment
- Git as single source of truth
- Automated sync from repository

### Security Implementations
- Network policies for pod isolation
- Security groups with least privilege
- KMS key rotation enabled
- Encrypted EBS volumes
- OIDC provider for workload identity

## Running This Project

See [SECURITY.md](SECURITY.md) for important security considerations before deployment.

**Note:** This is a demonstration environment. Production deployments should implement additional hardening based on your security requirements.
