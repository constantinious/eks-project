# Prod environment backend configuration
# Usage: terraform init -backend-config=environments/prod/backend.hcl

bucket         = "eks-portfolio-terraform-state-prod"
key            = "prod/eks-cluster/terraform.tfstate"
region         = "eu-west-1"
dynamodb_table = "terraform-state-lock-prod"
encrypt        = true
