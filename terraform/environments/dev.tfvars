# AWS Configuration
aws_region   = "us-west-2"
environment  = "dev"
project_name = "eks-demo"
owner        = "devops-team"

# EKS Cluster Configuration
cluster_name    = "demo-cluster"
cluster_version = "1.32"

# Node Group Configuration
node_instance_types     = ["t3.medium"]
node_group_min_size     = 1
node_group_max_size     = 4
node_group_desired_size = 2

# VPC Configuration
vpc_cidr             = "10.0.0.0/16"
availability_zones   = ["us-west-2a", "us-west-2b"]
private_subnet_cidrs = ["10.0.1.0/24", "10.0.2.0/24"]
public_subnet_cidrs  = ["10.0.101.0/24", "10.0.102.0/24"]

# Enable single NAT gateway to reduce costs
enable_nat_gateway = true
single_nat_gateway = true

# ECR Configuration
ecr_repository_name      = "demo-app"
ecr_image_tag_mutability = "MUTABLE"
ecr_scan_on_push         = true

# Additional tags
additional_tags = {
  CreatedBy  = "terraform"
  CostCenter = "engineering"
}

# EKS Addons Configuration
enable_addons = true

# Domain Configuration (optional - set to enable cert-manager and external-dns with Route53)
domain_name       = "novairis.xyz"
certificate_email = "novairis@gmail.com"

# Addon Versions (optional - defaults will be used if not specified)
aws_load_balancer_controller_version = "1.8.1"
external_dns_version                 = "1.14.5"

# Metrics Server Configuration
enable_metrics_server = true

# AWS Auth Configuration for EKS access
ci_cd_role_arn = "arn:aws:iam::940495689171:role/GitHubActionsEKSDeploymentRole"
local_user_arn = "arn:aws:iam::940495689171:user/Learner"
