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

# Note: cert-manager has been replaced with AWS Certificate Manager (ACM)
# ACM automatically handles certificate provisioning and renewal through DNS validation
# The load balancer controller will automatically discover certificates from ACM
# based on the domain names specified in ingress resources
