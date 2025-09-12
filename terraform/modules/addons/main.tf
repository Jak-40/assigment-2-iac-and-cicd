# main.tf - Main addons module file

# Data source for current AWS account
data "aws_caller_identity" "current" {}

# Wait for the EKS cluster to be ready before installing addons
resource "time_sleep" "wait_for_cluster" {
  create_duration = "60s"

  triggers = {
    cluster_name = var.cluster_name
    oidc_arn     = var.eks_oidc_provider_arn
  }
}

# Kubernetes Metrics Server addon
resource "aws_eks_addon" "metrics_server" {
  count = var.enable_metrics_server ? 1 : 0

  cluster_name  = var.cluster_name
  addon_name    = "metrics-server"
  addon_version = var.metrics_server_version

  # Configuration for conflict resolution
  resolve_conflicts_on_create = "OVERWRITE"
  resolve_conflicts_on_update = "OVERWRITE"

  tags = var.tags

  depends_on = [time_sleep.wait_for_cluster]
}

# Note: cert-manager has been replaced with AWS Certificate Manager (ACM)
# ACM automatically handles certificate provisioning and renewal through DNS validation
# The load balancer controller will automatically discover certificates from ACM
# based on the domain names specified in ingress resources
