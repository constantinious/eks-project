# 🚀 EKS Portfolio Project

Production-ready AWS EKS infrastructure demonstrating DevOps best practices using Terraform, with complete CI/CD pipeline integration.

![Terraform](https://img.shields.io/badge/Terraform-%3E%3D1.5.0-844FBA?logo=terraform)
![AWS](https://img.shields.io/badge/AWS-EKS_1.29-FF9900?logo=amazonaws)
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
    ┌──────────┐                    │  │  │  │         EKS Cluster (v1.29)        │    │ │ │
    │   KMS    │                    │  │  │  │                                     │    │ │ │
    │  Keys    │──── Encryption     │  │  │  │  ┌─────────┐ ┌──────────────────┐  │    │ │ │
    └──────────┘                    │  │  │  │  │Demo App │ │  ALB Controller  │  │    │ │ │
                                    │  │  │  │  │ (2048)  │ │  ExternalDNS     │  │    │ │ │
    ┌──────────┐                    │  │  │  │  │  HPA    │ │  Metrics Server  │  │    │ │ │
    │CloudWatch│◄──── Logs          │  │  │  │  └─────────┘ └──────────────────┘  │    │ │ │
    │  Logs    │                    │  │  │  │                                     │    │ │ │
    └──────────┘                    │  │  │  │  ┌───────────────────────────────┐  │    │ │ │
                                    │  │  │  │  │    Managed Node Group         │  │    │ │ │
                                    │  │  │  │  │    t3.medium | 2-10 nodes    │  │    │ │ │
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
│   │   └── security/              # KMS keys, security groups
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
| **IRSA** | IAM Roles for Service Accounts (ALB Controller, ExternalDNS, Cluster Autoscaler) |
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

- **Terraform** >= 1.5.0 ([Install](https://developer.hashicorp.com/terraform/install))
- **AWS CLI** v2 ([Install](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html))
- **kubectl** ([Install](https://kubernetes.io/docs/tasks/tools/))
- **Helm** v3 ([Install](https://helm.sh/docs/intro/install/))
- **AWS Account** with appropriate IAM permissions
- **S3 Bucket** for Terraform remote state (optional but recommended)
- **DynamoDB Table** for state locking (optional but recommended)

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

Create the S3 bucket and DynamoDB table for state management:

```bash
# Create S3 bucket for state
aws s3api create-bucket \
  --bucket eks-portfolio-terraform-state-dev \
  --region eu-west-1 \
  --create-bucket-configuration LocationConstraint=eu-west-1

# Enable versioning
aws s3api put-bucket-versioning \
  --bucket eks-portfolio-terraform-state-dev \
  --versioning-configuration Status=Enabled

# Enable encryption
aws s3api put-bucket-encryption \
  --bucket eks-portfolio-terraform-state-dev \
  --server-side-encryption-configuration '{"Rules":[{"ApplyServerSideEncryptionByDefault":{"SSEAlgorithm":"aws:kms"}}]}'

# Create DynamoDB table for state locking
aws dynamodb create-table \
  --table-name terraform-state-lock-dev \
  --attribute-definitions AttributeName=LockID,AttributeType=S \
  --key-schema AttributeName=LockID,KeyType=HASH \
  --billing-mode PAY_PER_REQUEST \
  --region eu-west-1
```

Then uncomment the backend configuration in `terraform/versions.tf`.

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
  --name eks-portfolio-dev \
  --region eu-west-1
```

### Step 8: Deploy Application

```bash
# Apply all Kubernetes manifests
kubectl apply -f kubernetes/manifests/

# Verify deployment
kubectl get all -n demo-app

# Check HPA status
kubectl get hpa -n demo-app

# Get ALB DNS name
kubectl get ingress -n demo-app
```

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
| Node instance type | t3.medium | t3.large |
| Node min/max | 2/5 | 3/10 |
| Node disk size | 30 GB | 50 GB |
| API endpoint CIDR | 0.0.0.0/0 | Restricted |
| VPC CIDR | 10.0.0.0/16 | 10.1.0.0/16 |

### Enabling DNS/TLS (Optional)

To enable Route53 and ACM integration:

1. Set `create_dns_resources = true` in your tfvars
2. Configure `domain_name` and `hosted_zone_id`
3. Uncomment the ACM and ExternalDNS annotations in `kubernetes/manifests/03-ingress.yaml`
4. Re-apply Terraform and Kubernetes manifests

---

## 📊 Monitoring & Observability

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
aws s3 rb s3://eks-portfolio-terraform-state-dev --force
aws dynamodb delete-table --table-name terraform-state-lock-dev --region eu-west-1
```

---

## 🔄 CI/CD Pipeline

The GitHub Actions workflow (`.github/workflows/terraform.yml`) provides:

| Stage | Trigger | Action |
|---|---|---|
| **Validate** | All PRs & pushes | `terraform fmt`, `init`, `validate` |
| **Security** | After validation | Checkov security scan |
| **Plan** | PRs & manual | `terraform plan` with PR comments |
| **Apply** | Manual only | `terraform apply` with approval |

### Setup

1. Create an IAM role for GitHub Actions with OIDC federation
2. Add `AWS_ROLE_ARN` as a repository secret
3. Configure environment protection rules for `prod`

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
- [Cluster Autoscaler](https://github.com/kubernetes/autoscaler/tree/master/cluster-autoscaler)
