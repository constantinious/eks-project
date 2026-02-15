# Dev environment backend configuration
# Usage: terraform init -backend-config=environments/dev/backend.hcl

bucket         = "eks-portfolio-terraform-state-dev"
key            = "dev/eks-cluster/terraform.tfstate"
region         = "eu-west-1"
dynamodb_table = "terraform-state-lock-dev"
encrypt        = true
