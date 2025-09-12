# variables.tf - Input variables for the infrastructure

variable "aws_region" {
  description = "AWS region for all resources"
  type        = string
  default     = "us-west-2"
}

variable "environment" {
  description = "Environment name (e.g., dev, staging, prod)"
  type        = string
  default     = "dev"
}

variable "project_name" {
  description = "Name of the project"
  type        = string
  default     = "eks-demo"
}

variable "owner" {
  description = "Owner or team responsible for the infrastructure"
  type        = string
  default     = "devops-team"
}

variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
  default     = "demo-cluster"
}

variable "cluster_version" {
  description = "Kubernetes version for the EKS cluster"
  type        = string
  default     = "1.28"
}

variable "node_instance_types" {
  description = "EC2 instance types for EKS node groups"
  type        = list(string)
  default     = ["t3.medium"]
}

variable "node_group_min_size" {
  description = "Minimum number of nodes in the node group"
  type        = number
  default     = 1
}

variable "node_group_max_size" {
  description = "Maximum number of nodes in the node group"
  type        = number
  default     = 4
}

variable "node_group_desired_size" {
  description = "Desired number of nodes in the node group"
  type        = number
  default     = 2
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "availability_zones" {
  description = "List of availability zones"
  type        = list(string)
  default     = ["us-west-2a", "us-west-2b"]
}

variable "private_subnet_cidrs" {
  description = "CIDR blocks for private subnets"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "public_subnet_cidrs" {
  description = "CIDR blocks for public subnets"
  type        = list(string)
  default     = ["10.0.101.0/24", "10.0.102.0/24"]
}

variable "enable_nat_gateway" {
  description = "Enable NAT Gateway for private subnets"
  type        = bool
  default     = true
}

variable "single_nat_gateway" {
  description = "Use a single NAT Gateway for all private subnets"
  type        = bool
  default     = true
}

variable "ecr_repository_name" {
  description = "Name of the ECR repository"
  type        = string
  default     = "demo-app"
}

variable "ecr_image_tag_mutability" {
  description = "The tag mutability setting for the repository"
  type        = string
  default     = "MUTABLE"
}

variable "ecr_scan_on_push" {
  description = "Indicates whether images are scanned after being pushed to the repository"
  type        = bool
  default     = true
}

variable "additional_tags" {
  description = "Additional tags to apply to all resources"
  type        = map(string)
  default     = {}
}

variable "enable_addons" {
  description = "Enable EKS addons (AWS Load Balancer Controller, External DNS, etc.)"
  type        = bool
  default     = true
}

variable "domain_name" {
  description = "Domain name for Route53 hosted zone and SSL certificates"
  type        = string
  default     = ""
}

variable "certificate_email" {
  description = "Email address for Let's Encrypt certificates"
  type        = string
  default     = ""
}

variable "aws_load_balancer_controller_version" {
  description = "Version of the AWS Load Balancer Controller"
  type        = string
  default     = "1.8.1"
}

variable "external_dns_version" {
  description = "Version of External DNS"
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
  default     = null
}

# AWS Auth Configuration
variable "ci_cd_role_arn" {
  description = "IAM Role ARN for CI/CD (GitHub Actions) access to EKS"
  type        = string
  default     = ""
}

variable "local_user_arn" {
  description = "IAM User ARN for local development access to EKS"
  type        = string
  default     = ""
}
