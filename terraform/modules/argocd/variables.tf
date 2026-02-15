variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
}

variable "addon_version" {
  description = "Version of the ArgoCD EKS add-on"
  type        = string
  default     = null # Uses latest compatible version
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
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
