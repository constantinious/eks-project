terraform {
  required_version = ">= 1.10.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.35"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.17"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "~> 4.0"
    }
    kubectl = {
      source  = "alekc/kubectl"
      version = "~> 2.1"
    }
  }

  # S3 backend with native S3 state locking (no DynamoDB needed)
  # Locally: export AWS_PROFILE=terraform_user before running terraform
  # CI: credentials are injected via OIDC (configure-aws-credentials action)
  backend "s3" {
    bucket       = "eks-portfolio-terraform-state"
    key          = "eks-cluster/terraform.tfstate"
    region       = "eu-west-1"
    use_lockfile = true
    encrypt      = true
  }
}
