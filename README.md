# 🚀 EKS Portfolio Project

Production-ready AWS EKS infrastructure demonstrating DevOps best practices using Terraform, with complete CI/CD pipeline integration.

![Terraform](https://img.shields.io/badge/Terraform-%3E%3D1.10.0-844FBA?logo=terraform)
![AWS](https://img.shields.io/badge/AWS-EKS_1.35-FF9900?logo=amazonaws)
![License](https://img.shields.io/badge/License-MIT-blue)

---

## 📐 Architecture

```
                                    ┌─────────────────────────────────────────────────────┐
                                    │                    AWS Cloud                         │
                                    │                                                     │
    ┌──────────┐                    │  ┌─────────────────────────────────────────────────┐ │
    │          │   HTTPS (443)      │  │              VPC (10.0.0.0/16)                  │ │
    │  Users   │ ──────────────────►│  │                                                 │ │
    │          │                    │  │  ┌──────────── Public Subnets ────────────────┐ │ │
    └──────────┘                    │  │  │                                            │ │ │
                                    │  │  │  ┌─────────────────────────────────────┐   │ │ │
    ┌──────────┐                    │  │  │  │    Application Load Balancer (ALB)  │   │ │ │
    │ Route53  │◄──── ExternalDNS   │  │  │  │    - SSL termination (ACM cert)    │   │ │ │
    │   DNS    │                    │  │  │  │    - Internet-facing               │   │ │ │
    └──────────┘                    │  │  │  └──────────────┬──────────────────────┘   │ │ │
                                    │  │  │    NAT Gateway  │                          │ │ │
    ┌──────────┐                    │  │  └─────────────────┼──────────────────────────┘ │ │
    │   ACM    │                    │  │                    │                             │ │
    │  Cert    │                    │  │  ┌──────────── Private Subnets ───────────────┐ │ │
    └──────────┘                    │  │  │                 │                           │ │ │
                                    │  │  │  ┌──────────────▼──────────────────────┐    │ │ │
    ┌──────────┐                    │  │  │  │         EKS Cluster (v1.35)        │    │ │ │
    │   KMS    │                    │  │  │  │                                     │    │ │ │
    │  Keys    │──── Encryption     │  │  │  │  ┌─────────┐ ┌──────────────────┐  │    │ │ │
    └──────────┘                    │  │  │  │  │Demo App │ │  ALB Controller  │  │    │ │ │
                                    │  │  │  │  │ (2048)  │ │  ExternalDNS     │  │    │ │ │
    ┌──────────┐                    │  │  │  │  │  HPA    │ │  Metrics Server  │  │    │ │ │
    │CloudWatch│◄──── Logs          │  │  │  │  └─────────┘ └──────────────────┘  │    │ │ │
    │  Logs    │                    │  │  │  │                                     │    │ │ │
    └──────────┘                    │  │  │  │  ┌───────────────────────────────┐  │    │ │ │
                                    │  │  │  │  │    Managed Node Group         │  │    │ │ │
                                    │  │  │  │  │    t4g.medium | 2-10 nodes   │  │    │ │ │
                                    │  │  │  │  │    Encrypted EBS (gp3)       │  │    │ │ │
                                    │  │  │  │  │    IMDSv2 enforced           │  │    │ │ │
                                    │  │  │  │  └───────────────────────────────┘  │    │ │ │
                                    │  │  │  └─────────────────────────────────────┘    │ │ │
                                    │  │  └────────────────────────────────────────────┘ │ │
                                    │  └─────────────────────────────────────────────────┘ │
                                    └─────────────────────────────────────────────────────┘
```

---

## 📁 Project Structure

```
eks-portfolio-project/
├── .github/
│   └── workflows/
│       └── terraform.yml          # CI/CD pipeline
├── terraform/
│   ├── modules/
│   │   ├── vpc/                   # VPC, subnets, NAT, flow logs
│   │   ├── eks/                   # EKS cluster, node groups, IRSA
│   │   ├── alb-controller/        # AWS Load Balancer Controller (Helm)
│   │   ├── route53/               # ExternalDNS, ACM certificate
│   │   ├── argocd/                # ArgoCD EKS add-on for GitOps
│   │   ├── security/              # KMS keys, security groups
│   │   ├── ebs-csi/               # EBS CSI driver, gp3 StorageClass
│   │   ├── monitoring-storage/    # S3 buckets + IRSA for Loki & Tempo
│   │   └── monitoring-stack/      # Prometheus, Grafana, Loki, Tempo, Promtail
│   │       └── values/            # Helm values templates
│   ├── environments/
│   │   ├── dev/                   # Dev environment config
│   │   └── prod/                  # Prod environment config
│   ├── versions.tf                # Provider & Terraform version constraints
│   ├── main.tf                    # Root module - wires everything together
│   ├── variables.tf               # All configurable variables
│   └── outputs.tf                 # Important output values
├── kubernetes/
│   ├── manifests/                 # Application Kubernetes manifests
│   │   ├── 00-namespace.yaml
│   │   ├── 01-deployment.yaml     # 2048 demo app
│   │   ├── 02-service.yaml        # ClusterIP service
│   │   ├── 03-ingress.yaml        # ALB Ingress with annotations
│   │   ├── 04-hpa.yaml            # Horizontal Pod Autoscaler
│   │   ├── 05-network-policies.yaml
│   │   └── 06-pdb.yaml            # Pod Disruption Budget
│   ├── monitoring/                # Observability Kubernetes manifests
│   │   ├── servicemonitors/       # ServiceMonitor CRDs for Prometheus
│   │   │   ├── app-servicemonitor.yaml
│   │   │   └── nginx-ingress-servicemonitor.yaml
│   │   └── rules/                 # PrometheusRule CRDs for alerting
│   │       ├── node-alerts.yaml
│   │       ├── pod-alerts.yaml
│   │       ├── cluster-alerts.yaml
│   │       └── application-alerts.yaml
│   └── helm-values/               # Helm chart value overrides
│       ├── alb-controller-values.yaml
│       ├── external-dns-values.yaml
│       ├── metrics-server-values.yaml
│       └── cluster-autoscaler-values.yaml
├── .gitignore
└── README.md
```

---

## 🔐 Security Features

| Feature | Implementation |
|---|---|
| **Encryption at rest** | KMS keys for EKS secrets and EBS volumes |
| **Encryption in transit** | TLS everywhere via ACM certificates at ALB |
| **IRSA** | IAM Roles for Service Accounts (ALB Controller, ExternalDNS, Cluster Autoscaler, Loki, Tempo, EBS CSI) |
| **IMDSv2** | Instance Metadata Service v2 enforced on all nodes |
| **Private nodes** | All worker nodes in private subnets only |
| **Network policies** | Default deny ingress + explicit allow rules |
| **Security groups** | Minimal required rules for cluster and nodes |
| **VPC Flow Logs** | Full traffic logging to CloudWatch |
| **Control plane logs** | API, audit, authenticator, controller manager, scheduler |
| **API endpoint restriction** | CIDR-based access control for EKS API server |
| **Pod security** | `runAsNonRoot`, dropped capabilities, resource limits |
| **EKS Access Entries** | Modern access management (replaces aws-auth ConfigMap) |

---

## 📋 Prerequisites

- **Terraform** >= 1.10.0 ([Install](https://developer.hashicorp.com/terraform/install))
- **AWS CLI** v2 ([Install](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html))
- **kubectl** ([Install](https://kubernetes.io/docs/tasks/tools/))
- **Helm** v3 ([Install](https://helm.sh/docs/intro/install/))
- **AWS Account** with appropriate IAM permissions
- **S3 Bucket** for Terraform remote state (uses native S3 locking, no DynamoDB needed)

### Required IAM Permissions

The deploying user/role needs permissions for:
- EKS (full access)
- EC2 (VPC, subnets, security groups, EIPs, NAT gateways)
- IAM (roles, policies, OIDC providers)
- KMS (key management)
- CloudWatch Logs
- Elastic Load Balancing
- Route53 (if using DNS features)
- ACM (if using certificate features)
- S3 & DynamoDB (for Terraform state)

---

## 🚀 Deployment Guide

### Step 1: Clone the Repository

```bash
git clone https://github.com/constantinious/eks-project.git
cd eks-project
```

### Step 2: Configure Remote State (Recommended)

Create the S3 bucket for state management with native S3 locking:

```bash
# Create S3 bucket for state
aws s3api create-bucket \
  --bucket eks-portfolio-terraform-state \
  --region eu-west-1 \
  --create-bucket-configuration LocationConstraint=eu-west-1

# Enable versioning (required for S3 native locking)
aws s3api put-bucket-versioning \
  --bucket eks-portfolio-terraform-state \
  --versioning-configuration Status=Enabled

# Enable encryption
aws s3api put-bucket-encryption \
  --bucket eks-portfolio-terraform-state \
  --server-side-encryption-configuration '{"Rules":[{"ApplyServerSideEncryptionByDefault":{"SSEAlgorithm":"aws:kms"}}]}'

# Block public access
aws s3api put-public-access-block \
  --bucket eks-portfolio-terraform-state \
  --public-access-block-configuration \
    "BlockPublicAcls=true,IgnorePublicAcls=true,BlockPublicPolicy=true,RestrictPublicBuckets=true"
```

> **Note:** This configuration uses Terraform 1.10+ native S3 state locking with `use_lockfile = true`. No DynamoDB table needed!

### Step 3: Configure Variables

```bash
# Copy the example tfvars for your environment
cp terraform/environments/dev/terraform.tfvars.example terraform/environments/dev/terraform.tfvars

# Edit with your values
vim terraform/environments/dev/terraform.tfvars
```

### Step 4: Initialize Terraform

```bash
cd terraform

# Without remote state
terraform init

# With remote state
terraform init -backend-config=environments/dev/backend.hcl
```

### Step 5: Plan Infrastructure

```bash
terraform plan -var-file="environments/dev/terraform.tfvars"
```

### Step 6: Apply Infrastructure

```bash
terraform apply -var-file="environments/dev/terraform.tfvars"
```

> ⏱️ **Note:** EKS cluster creation takes approximately 10-15 minutes.

### Step 7: Configure kubectl

```bash
aws eks update-kubeconfig \
  --name eks-portfolio-Dev \
  --region eu-west-1
```

### Step 8: Deploy Application

**Option A: GitOps with ArgoCD (Recommended for Production)**

ArgoCD is deployed as an AWS EKS add-on and automatically syncs your Kubernetes manifests from the `main` branch:

```bash
# ArgoCD is automatically deployed by Terraform
# Check ArgoCD status
kubectl get pods -n argocd

# Get ArgoCD admin password
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath='{.data.password}' | base64 -d && echo

# Access ArgoCD UI (port-forward)
kubectl port-forward svc/argo-cd-argocd-server -n argocd 8080:443
# Then open: https://localhost:8080
# Username: admin
# Password: (from command above)

# Check Application sync status
kubectl get applications -n argocd
kubectl describe application demo-app -n argocd
```

**How GitOps Works:**
1. Push changes to `kubernetes/manifests/` directory
2. Commit and push to `main` branch
3. ArgoCD detects changes within 3 minutes (or click "Sync" in UI)
4. ArgoCD automatically applies changes to cluster
5. Resources removed from Git are automatically deleted (auto-prune enabled)

**Option B: Manual kubectl apply (Development Only)**

```bash
# Apply all Kubernetes manifests manually
kubectl apply -f kubernetes/manifests/

# Verify deployment
kubectl get all -n demo-app

# Check HPA status
kubectl get hpa -n demo-app

# Get ALB DNS name
kubectl get ingress -n demo-app
```

> 💡 **Best Practice:** Use ArgoCD for all environments. Manual `kubectl apply` should only be used for local testing or troubleshooting.

### Step 9: Access the Application

Get the ALB DNS name from the Ingress resource:

```bash
kubectl get ingress demo-app -n demo-app -o jsonpath='{.status.loadBalancer.ingress[0].hostname}'
```

Open the URL in your browser to see the 2048 game! 🎮

---

## 🔧 Configuration

### Environment Differences

| Parameter | Dev | Prod |
|---|---|---|
| NAT Gateways | 1 (cost optimization) | 3 (one per AZ - HA) |
| Node instance type | t4g.medium (ARM Graviton) | t3.large |
| Node min/max | 2/5 | 3/10 |
| Node disk size | 30 GB | 50 GB |
| API endpoint CIDR | 0.0.0.0/0 | Restricted |
| VPC CIDR | 10.0.0.0/16 | 10.1.0.0/16 |
| Environment tag | Dev | Prod |
| Monitoring | Enabled (compact retention) | Enabled (full retention) |

### Enabling DNS/TLS (Optional)

To enable Route53 and ACM integration:

1. Set `create_dns_resources = true` in your tfvars
2. Configure `domain_name` and `hosted_zone_id`
3. Uncomment the ACM and ExternalDNS annotations in `kubernetes/manifests/03-ingress.yaml`
4. Re-apply Terraform and Kubernetes manifests

---

## 📊 Monitoring & Observability

The project includes a complete open-source observability stack deployed via Terraform, providing metrics, logs, and distributed traces with full correlation.

### Observability Architecture

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                         monitoring namespace                                │
│                                                                             │
│  ┌──────────────┐     ┌────────────────┐     ┌──────────────────────────┐  │
│  │   Promtail   │────►│     Loki       │────►│  S3 (Loki logs bucket)   │  │
│  │  (DaemonSet) │     │ (Log backend)  │     │  Lifecycle: 14d dev /    │  │
│  │  all nodes   │     │  SingleBinary  │     │            90d prod      │  │
│  └──────────────┘     └───────┬────────┘     └──────────────────────────┘  │
│                               │ datasource                                  │
│  ┌──────────────┐     ┌───────▼────────┐     ┌──────────────────────────┐  │
│  │  Prometheus  │────►│    Grafana     │◄────│       Tempo              │  │
│  │  (Metrics)   │     │  (Dashboards)  │     │  (Distributed tracing)   │  │
│  │  15d / 30d   │     │  port :3000    │     │  OTLP / Jaeger / Zipkin  │  │
│  └──────┬───────┘     └────────────────┘     └───────────┬──────────────┘  │
│         │                                                │                  │
│  ┌──────▼───────┐                                ┌───────▼──────────────┐  │
│  │ AlertManager │                                │ S3 (Tempo traces     │  │
│  │  (Routing)   │                                │     bucket)          │  │
│  │  critical /  │                                │  Lifecycle: 3d dev / │  │
│  │  warning     │                                │            14d prod  │  │
│  └──────────────┘                                └──────────────────────┘  │
│                                                                             │
│  Network Policies: default-deny → allow internal → explicit allow rules     │
│  Resource Quotas: 8/16 CPU, 16Gi/32Gi memory, 20 PVCs                     │
└─────────────────────────────────────────────────────────────────────────────┘
```

### Stack Components

| Component | Version | Purpose |
|---|---|---|
| **kube-prometheus-stack** | 67.9.0 | Prometheus, Grafana, AlertManager, node-exporter, kube-state-metrics |
| **Loki** | 6.24.0 | Log aggregation with S3 backend (IRSA) |
| **Promtail** | 6.16.6 | Log collection DaemonSet with JSON parsing |
| **Tempo** | 1.14.0 | Distributed tracing with S3 backend (IRSA) |
| **EBS CSI Driver** | 2.37.0 | gp3 StorageClass for monitoring PVCs |

### Pre-configured Grafana Dashboards

| Dashboard | ID | Description |
|---|---|---|
| Kubernetes Cluster Overview | 7249 | Cluster-wide resource usage |
| Kubernetes Pods | 6417 | Per-pod CPU, memory, network |
| Node Exporter Full | 1860 | Detailed host metrics |
| Kubernetes API Server | 12006 | API server performance & errors |
| NGINX Ingress | 2 | Ingress request rate & latency |

### Alerting Rules

The following PrometheusRules are included in `kubernetes/monitoring/rules/`:

| Category | Alerts |
|---|---|
| **Node** | CPU > 80%/95%, Memory > 85%/95%, Disk > 85%/95%, Node NotReady |
| **Pod** | Frequent restarts (>5/hr), OOMKilled, CrashLoopBackOff, Stuck Pending, CPU throttling > 50% |
| **Cluster** | HPA at max replicas, PVC > 85%/95%, Certificate expiry < 7d, Deployment/StatefulSet/DaemonSet mismatch, API server 5xx > 3% |
| **Application** | HTTP 5xx > 5%, p99 latency > 1s, HTTP 4xx > 25%, Zero request rate |

### Accessing the Monitoring Stack

```bash
# Port-forward Grafana (default credentials: admin / <grafana_admin_password>)
kubectl port-forward -n monitoring svc/kube-prometheus-stack-grafana 3000:80

# Port-forward Prometheus
kubectl port-forward -n monitoring svc/kube-prometheus-stack-prometheus 9090:9090

# Port-forward AlertManager
kubectl port-forward -n monitoring svc/kube-prometheus-stack-alertmanager 9093:9093
```

### Applying Custom ServiceMonitors & Rules

After the cluster is running with the monitoring stack:

```bash
# Apply ServiceMonitors for custom app scraping
kubectl apply -f kubernetes/monitoring/servicemonitors/

# Apply alerting rules
kubectl apply -f kubernetes/monitoring/rules/

# Verify
kubectl get servicemonitors -n monitoring
kubectl get prometheusrules -n monitoring
```

### Environment Configuration

| Parameter | Dev | Prod |
|---|---|---|
| Prometheus retention | 7d | 30d |
| Prometheus PVC | 20Gi | 100Gi |
| Loki retention (S3) | 14 days | 90 days |
| Tempo retention (S3) | 3 days | 14 days |
| S3 force destroy | true | false |

### EKS Control Plane Logs

Available in CloudWatch at `/aws/eks/<cluster-name>/cluster`:
- **API Server** - Kubernetes API audit trail
- **Audit** - Who did what and when
- **Authenticator** - Authentication decisions
- **Controller Manager** - Controller operations
- **Scheduler** - Pod scheduling decisions

### VPC Flow Logs

Available in CloudWatch at `/aws/vpc-flow-log/<project>-<env>`:
- All network traffic in/out of the VPC
- Useful for security analysis and troubleshooting

### Application Metrics

The metrics-server provides:
- CPU and memory utilization per pod
- Used by HPA for autoscaling decisions

```bash
# Check node resource usage
kubectl top nodes

# Check pod resource usage
kubectl top pods -n demo-app
```

---

## 🧹 Cleanup

### Remove Kubernetes Resources

```bash
kubectl delete -f kubernetes/manifests/
```

### Destroy Infrastructure

```bash
cd terraform
terraform destroy -var-file="environments/dev/terraform.tfvars"
```

> ⚠️ **Important:** Always delete Kubernetes resources (especially Ingress/ALB) before destroying Terraform infrastructure to avoid orphaned resources.

### Clean Up State Resources

```bash
# Delete S3 state bucket (caution: this removes all state history)
aws s3 rb s3://eks-portfolio-terraform-state --force
```

---

## 🔄 CI/CD Pipeline

The GitHub Actions workflow (`.github/workflows/terraform.yml`) provides:

| Stage | Trigger | Action |
|---|---|---|
| **Validate** | All PRs & pushes | `terraform fmt`, `init`, `validate` |
| **Security** | After validation | Checkov security scan |
| **Plan** | PRs only | `terraform plan` with PR comments |
| **Cost Estimate** | PRs only | Infracost monthly cost breakdown |
| **Apply** | Merge to main | `terraform apply` (auto-approve) |
| **Destroy** | Manual only | `terraform destroy` with approval |

### Cost Estimation with Infracost

The pipeline includes automated cost estimation on every PR:
- Generates baseline cost from `main` branch
- Compares with PR changes to show cost diff
- Posts monthly cost breakdown as PR comment
- Helps prevent cost surprises before infrastructure changes are applied

### Setup

1. Create an IAM role for GitHub Actions with OIDC federation:
   ```bash
   # Create OIDC identity provider
   aws iam create-open-id-connect-provider \
     --url https://token.actions.githubusercontent.com \
     --client-id-list sts.amazonaws.com \
     --thumbprint-list 6938fd4d98bab03faadb97b34396831e3780aea1
   
   # Create trust policy and IAM role (see AWS OIDC docs)
   ```
2. Add GitHub repository secrets:
   - `AWS_ROLE_ARN` - IAM role for Terraform operations
   - `INFRACOST_API_KEY` - API key from [infracost.io](https://www.infracost.io/)
3. Configure environment protection rules for `production` (if using destroy workflow)

---

## 🤖 GitOps with ArgoCD

This project uses **ArgoCD as an AWS EKS add-on** for continuous deployment of Kubernetes manifests. ArgoCD provides declarative GitOps for application delivery.

### Features

- ✅ **AWS Native Integration**: Deployed via EKS add-on (managed by AWS)
- ✅ **Automatic Sync**: Monitors `main` branch every 3 minutes
- ✅ **Auto-Prune**: Removes resources deleted from Git
- ✅ **Self-Heal**: Corrects manual changes back to Git state
- ✅ **Zero Manual kubectl**: Push to Git, ArgoCD handles the rest

### Architecture

```
┌─────────────┐          ┌──────────────┐          ┌─────────────────┐
│   GitHub    │          │   ArgoCD     │          │   EKS Cluster   │
│  (main)     │──watch──►│   Server     │──sync───►│   (demo-app)    │
│             │          │  (argocd ns) │          │                 │
└─────────────┘          └──────────────┘          └─────────────────┘
      │                         │                           │
      │  1. Push manifests      │  2. Detect changes        │  3. Apply changes
      │     to main branch      │     within 3 min          │     automatically
      │                         │                           │
      └─────────────────────────┴───────────────────────────┘
                     Full GitOps Workflow
```

### ArgoCD Configuration

The ArgoCD Application is automatically created by Terraform and configured to:

```yaml
spec:
  project: default
  source:
    repoURL: https://github.com/constantinious/eks-project.git
    targetRevision: main
    path: kubernetes/manifests
  destination:
    server: https://kubernetes.default.svc
    namespace: demo-app
  syncPolicy:
    automated:
      prune: true      # Delete resources removed from Git
      selfHeal: true   # Revert manual changes
    syncOptions:
      - CreateNamespace=true
```

### Accessing ArgoCD UI

```bash
# Get admin password
kubectl -n argocd get secret argocd-initial-admin-secret \
  -o jsonpath='{.data.password}' | base64 -d && echo

# Port forward to access UI
kubectl port-forward svc/argo-cd-argocd-server -n argocd 8080:443

# Open browser to https://localhost:8080
# Username: admin
# Password: (from command above)
```

### ArgoCD CLI (Optional)

```bash
# Install ArgoCD CLI
brew install argocd  # macOS
# or
curl -sSL -o argocd https://github.com/argoproj/argo-cd/releases/latest/download/argocd-linux-amd64
chmod +x argocd
sudo mv argocd /usr/local/bin/

# Login
argocd login localhost:8080

# List applications
argocd app list

# Sync application manually
argocd app sync demo-app

# View application details
argocd app get demo-app

# View sync history
argocd app history demo-app
```

### GitOps Workflow

**Deploying Changes:**

1. **Edit manifests locally**
   ```bash
   # Update deployment replicas
   vim kubernetes/manifests/01-deployment.yaml
   ```

2. **Commit and push to main**
   ```bash
   git add kubernetes/manifests/01-deployment.yaml
   git commit -m "feat: scale demo-app to 3 replicas"
   git push origin main
   ```

3. **ArgoCD syncs automatically**
   - ArgoCD detects changes within 3 minutes
   - Applies changes to cluster
   - Shows sync status in UI

4. **Verify deployment**
   ```bash
   kubectl get pods -n demo-app
   # or check ArgoCD UI
   ```

**Rolling Back:**

```bash
# Option 1: Revert Git commit
git revert HEAD
git push origin main
# ArgoCD will automatically sync the revert

# Option 2: Use ArgoCD UI
# Navigate to app → History → Select previous revision → Rollback

# Option 3: Use ArgoCD CLI
argocd app rollback demo-app <revision-id>
```

### Disabling ArgoCD (Optional)

If you prefer manual kubectl deployments:

```hcl
# In terraform/environments/dev/terraform.tfvars
enable_argocd = false
```

Then apply Terraform changes:
```bash
terraform apply -var-file="environments/dev/terraform.tfvars"
```

---

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Run `terraform fmt -recursive` before committing
4. Run `terraform validate` to check syntax
5. Submit a Pull Request

---

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

## 📚 References

- [Amazon EKS Documentation](https://docs.aws.amazon.com/eks/latest/userguide/)
- [Terraform AWS Provider](https://registry.terraform.io/providers/hashicorp/aws/latest)
- [AWS Load Balancer Controller](https://kubernetes-sigs.github.io/aws-load-balancer-controller/)
- [ExternalDNS](https://github.com/kubernetes-sigs/external-dns)
- [ArgoCD Documentation](https://argo-cd.readthedocs.io/)
- [EKS Add-ons - ArgoCD](https://docs.aws.amazon.com/eks/latest/userguide/eks-add-ons.html)
- [Cluster Autoscaler](https://github.com/kubernetes/autoscaler/tree/master/cluster-autoscaler)
- [kube-prometheus-stack](https://github.com/prometheus-community/helm-charts/tree/main/charts/kube-prometheus-stack)
- [Grafana Loki](https://grafana.com/docs/loki/latest/)
- [Grafana Tempo](https://grafana.com/docs/tempo/latest/)
- [Promtail](https://grafana.com/docs/loki/latest/send-data/promtail/)
- [EBS CSI Driver](https://github.com/kubernetes-sigs/aws-ebs-csi-driver)
