variable "chart_version" {
  description = "ArgoCD Helm chart version"
  type        = string
  default     = "7.7.15"
}

variable "enable_demo_app_sync" {
  description = "Enable automatic sync of demo app from Git"
  type        = bool
  default     = true
}

variable "git_repo_url" {
  description = "Git repository URL containing Kubernetes manifests"
  type        = string
  default     = "https://github.com/constantinious/eks-project.git"
}

variable "git_target_revision" {
  description = "Git branch, tag, or commit to sync from"
  type        = string
  default     = "main"
}

variable "git_manifests_path" {
  description = "Path in the Git repo containing Kubernetes manifests"
  type        = string
  default     = "kubernetes/manifests"
}

variable "auto_prune" {
  description = "Automatically delete resources that are no longer in Git"
  type        = bool
  default     = true
}

variable "auto_sync" {
  description = "Automatically sync when Git repo changes are detected"
  type        = bool
  default     = true
}
