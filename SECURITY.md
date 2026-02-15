# Security Guidelines for Public Repository

## 🔒 What's Protected

This repository is configured to prevent committing sensitive data:

### ✅ Safe to Commit
- Infrastructure as Code (Terraform modules)
- Kubernetes manifests (without secrets)
- Application code
- Documentation
- Configuration templates

### ⛔ Never Commit
- AWS credentials
- Passwords or API keys
- Private keys (*.pem, *.key)
- Kubeconfig files
- terraform.tfstate files (contain sensitive data)
- .env files with secrets

## 🛡️ Security Measures in Place

1. **`.gitignore` Protection**
   - Blocks common secret file patterns
   - Prevents state files from being committed
   - Excludes credential files

2. **Placeholder Values**
   - `grafana_admin_password = "CHANGE_ME"` requires override
   - AWS account IDs replaced with dynamic lookups
   - API keys use environment variables

3. **IAM Best Practices**
   - Uses IAM roles instead of hardcoded credentials
   - GitHub Actions OIDC for passwordless authentication
   - EKS access via IAM roles (not kubeconfig)

## 🔑 Managing Secrets

### For Terraform Variables

**Option 1: Environment Variables (Recommended)**
```bash
export TF_VAR_grafana_admin_password="your-secure-password"
terraform apply
```

**Option 2: Local tfvars file (Git-ignored)**
```bash
# Create local override file
cp terraform/environments/dev/terraform.tfvars terraform/environments/dev/terraform.tfvars.local

# Edit with real values
vim terraform/environments/dev/terraform.tfvars.local

# Apply with local file
terraform apply -var-file="environments/dev/terraform.tfvars.local"
```

**Option 3: CI/CD Secrets**
- Use GitHub Secrets for pipeline variables
- Never print sensitive values in logs

### For Kubernetes Secrets

**Use Kubernetes Secrets (not ConfigMaps)**
```bash
# Create secret from literal
kubectl create secret generic api-keys \
  --from-literal=weather-api-key='your-key' \
  --namespace demo-app

# Create secret from file
kubectl create secret generic tls-cert \
  --from-file=tls.crt \
  --from-file=tls.key \
  --namespace demo-app
```

**Or use External Secrets Operator** (recommended for production)
- Integrates with AWS Secrets Manager
- Automatic secret rotation
- Centralized secret management

### For Application Secrets

**Flask App Environment Variables**
```yaml
# In deployment.yaml
env:
  - name: OPENWEATHER_API_KEY
    valueFrom:
      secretKeyRef:
        name: api-keys
        key: weather-api-key
```

## 🔍 Before Pushing - Security Checklist

- [ ] No passwords in code or config files
- [ ] No AWS credentials committed
- [ ] No private keys in repository
- [ ] `.gitignore` is up to date
- [ ] Sensitive values use environment variables
- [ ] terraform.tfstate not committed
- [ ] No hardcoded AWS account IDs

## 🚨 If You Accidentally Commit Secrets

**Immediate Actions:**

1. **Rotate the exposed credentials immediately**
   ```bash
   # For AWS keys
   aws iam delete-access-key --access-key-id AKIAXXXXXX
   
   # For other secrets, change them in the service
   ```

2. **Remove from Git history** (requires force push)
   ```bash
   # Install BFG Repo Cleaner
   brew install bfg
   
   # Remove sensitive file from all commits
   bfg --delete-files sensitive-file.txt
   
   # Or replace text patterns
   bfg --replace-text passwords.txt
   
   # Force push (requires coordination with team)
   git push --force
   ```

3. **Report to GitHub** (for serious leaks)
   - GitHub will help remove cached versions

## 🔐 Additional Security Tools

**Scan for secrets before committing:**
```bash
# Install git-secrets
brew install git-secrets

# Configure for AWS
git secrets --register-aws

# Scan repository
git secrets --scan

# Add pre-commit hook
git secrets --install
```

**Use pre-commit hooks:**
```bash
# Install pre-commit
pip install pre-commit

# Create .pre-commit-config.yaml
cat > .pre-commit-config.yaml << 'EOF'
repos:
  - repo: https://github.com/Yelp/detect-secrets
    rev: v1.4.0
    hooks:
      - id: detect-secrets
EOF

# Install hooks
pre-commit install
```

## 📚 Resources

- [GitHub Security Best Practices](https://docs.github.com/en/code-security/getting-started/securing-your-repository)
- [AWS Security Best Practices](https://aws.amazon.com/security/best-practices/)
- [OWASP Secrets Management](https://cheatsheetseries.owasp.org/cheatsheets/Secrets_Management_CheatSheet.html)
- [Terraform Sensitive Data](https://www.terraform.io/docs/language/values/variables.html#suppressing-values-in-cli-output)

---

**Current Status**: ✅ Repository is safe to push to public GitHub with current configurations
