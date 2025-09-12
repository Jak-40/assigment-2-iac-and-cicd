# variables.tf - Variables for EKS addons module

variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
}

variable "aws_region" {
  description = "AWS region to deploy resources to"
  type        = string
}

variable "eks_oidc_provider_arn" {
  description = "ARN of the OIDC provider for the EKS cluster"
  type        = string
}

variable "cluster_oidc_issuer_url" {
  description = "URL of the OIDC issuer for the EKS cluster"
  type        = string
}

variable "vpc_id" {
  description = "ID of the VPC where the EKS cluster is deployed"
  type        = string
}

variable "domain_name" {
  description = "Domain name for Route53 hosted zone (required for ACM certificate creation)"
  type        = string
  default     = ""
}

variable "certificate_email" {
  description = "Email for certificate notifications (kept for compatibility but not used with ACM)"
  type        = string
  default     = "admin@example.com"
}

variable "aws_load_balancer_controller_version" {
  description = "Version of AWS Load Balancer Controller to install"
  type        = string
  default     = "1.8.1"
}

variable "external_dns_version" {
  description = "Version of External DNS to install"
  type        = string
  default     = "1.14.5"
}

variable "enable_metrics_server" {
  description = "Enable Kubernetes Metrics Server addon"
  type        = bool
  default     = true
}

variable "metrics_server_version" {
  description = "Version of the Kubernetes Metrics Server addon"
  type        = string
  default     = "v0.7.2"
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}
