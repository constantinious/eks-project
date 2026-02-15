# Deploying Prague Dashboard to EKS

## Quick Start Guide

### Option 1: Use Docker Hub (Recommended)

1. **Login to Docker Hub:**
   ```bash
   docker login
   ```

2. **Build and push the image:**
   ```bash
   cd /Users/konstantinosgkekas/Git-project/eks-project
   
   # Build
   docker build -t YOUR_DOCKERHUB_USERNAME/prague-dashboard:v1.2.0 demo-app/
   
   # Push
   docker push YOUR_DOCKERHUB_USERNAME/prague-dashboard:v1.2.0
   ```

3. **Update Kubernetes manifest:**
   
   Edit `kubernetes/manifests/01-deployment.yaml` line 29:
   ```yaml
   image: YOUR_DOCKERHUB_USERNAME/prague-dashboard:v1.2.0
   ```

4. **Commit and push to trigger ArgoCD:**
   ```bash
   git add .
   git commit -m "feat: deploy Prague dashboard app v1.2.0"
   git push origin main
   ```

5. **Wait for ArgoCD to sync** (up to 3 minutes) or manually trigger:
   ```bash
   kubectl patch application demo-app -n argocd --type merge -p '{"operation":{"sync":{"revision":"HEAD"}}}'
   ```

6. **Access the app:**
   ```bash
   # Via DNS (after ArgoCD sync)
   open http://demo.condevelop.net
   
   # Or check pods
   kubectl get pods -n demo-app
   ```

### Option 2: Use Amazon ECR (Alternative)

1. **Create ECR repository:**
   ```bash
   aws ecr create-repository \
     --repository-name prague-dashboard \
     --region eu-west-1 \
     --profile terraform_user
   ```

2. **Login to ECR:**
   ```bash
   aws ecr get-login-password --region eu-west-1 --profile terraform_user | \
     docker login --username AWS --password-stdin 992382750905.dkr.ecr.eu-west-1.amazonaws.com
   ```

3. **Build, tag, and push:**
   ```bash
   # Build
   docker build -t prague-dashboard:v1.2.0 demo-app/
   
   # Tag
   docker tag prague-dashboard:v1.2.0 \
     992382750905.dkr.ecr.eu-west-1.amazonaws.com/prague-dashboard:v1.2.0
   
   # Push
   docker push 992382750905.dkr.ecr.eu-west-1.amazonaws.com/prague-dashboard:v1.2.0
   ```

4. **Update Kubernetes manifest:**
   
   Edit `kubernetes/manifests/01-deployment.yaml` line 29:
   ```yaml
   image: 992382750905.dkr.ecr.eu-west-1.amazonaws.com/prague-dashboard:v1.2.0
   ```

5. **Commit and push** (same as Option 1 step 4)

### Option 3: Use GitHub Container Registry (GHCR)

1. **Create GitHub Personal Access Token:**
   - Go to GitHub Settings → Developer settings → Personal access tokens
   - Create token with `write:packages` permission

2. **Login to GHCR:**
   ```bash
   echo YOUR_GITHUB_TOKEN | docker login ghcr.io -u YOUR_GITHUB_USERNAME --password-stdin
   ```

3. **Build, tag, and push:**
   ```bash
   # Build
   docker build -t prague-dashboard:v1.2.0 demo-app/
   
   # Tag (use lowercase username)
   docker tag prague-dashboard:v1.2.0 \
     ghcr.io/YOUR_GITHUB_USERNAME/prague-dashboard:v1.2.0
   
   # Push
   docker push ghcr.io/YOUR_GITHUB_USERNAME/prague-dashboard:v1.2.0
   ```

4. **Update Kubernetes manifest:**
   
   Edit `kubernetes/manifests/01-deployment.yaml` line 29:
   ```yaml
   image: ghcr.io/YOUR_GITHUB_USERNAME/prague-dashboard:v1.2.0
   ```

5. **Commit and push** (same as Option 1 step 4)

---

## Local Testing

Test the app locally before deploying:

```bash
# Build
docker build -t prague-dashboard:test demo-app/

# Run on port 8081 (8080 might be in use)
docker run -d -p 8081:8080 --name prague-test prague-dashboard:test

# Test
curl http://localhost:8081/health
open http://localhost:8081

# Cleanup
docker rm -f prague-test
```

---

## What This App Does

- **Prague Weather**: Shows current temperature, conditions, humidity, wind speed
- **CZK/EUR Exchange**: Live currency conversion rates
- **Auto-refresh**: Updates every 5 minutes
- **Fallback data**: Works even if APIs are unavailable (shows demo data)
- **Health endpoint**: `/health` for Kubernetes probes

---

## Troubleshooting

**ArgoCD not syncing?**
```bash
# Check application status
kubectl get application demo-app -n argocd

# View logs
kubectl describe application demo-app -n argocd

# Manual sync
kubectl patch application demo-app -n argocd --type merge -p '{"operation":{"sync":{"revision":"HEAD"}}}'
```

**Pods not starting?**
```bash
# Check pod status
kubectl get pods -n demo-app

# View pod logs
kubectl logs -n demo-app -l app.kubernetes.io/name=demo-app

# Describe pod for events
kubectl describe pod -n demo-app -l app.kubernetes.io/name=demo-app
```

**Image pull errors?**
- Verify image exists in registry
- Check image name and tag in deployment manifest
- For private registries, create imagePullSecrets

---

**Current Status**: 
- ✅ Demo app code created in `demo-app/`
- ✅ Docker image built locally as `prague-dashboard:v1.2.0`
- ✅ Tested locally on port 8081
- ⏳ Waiting for you to push to a container registry
- ⏳ Then update the image in `kubernetes/manifests/01-deployment.yaml`
- ⏳ Commit and let ArgoCD deploy automatically
