# main.tf - Main infrastructure configuration

# Data source for current AWS account and region
data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

# Data source for available availability zones
data "aws_availability_zones" "available" {
  state = "available"
}

# Local values for common tags and naming
locals {
  name = "${var.project_name}-${var.environment}"
  common_tags = merge(
    {
      Environment = var.environment
      Project     = var.project_name
      ManagedBy   = "Terraform"
      Owner       = var.owner
    },
    var.additional_tags
  )
}

# VPC Module
module "vpc" {
  source = "./modules/vpc"

  name                 = local.name
  vpc_cidr             = var.vpc_cidr
  availability_zones   = slice(data.aws_availability_zones.available.names, 0, 2)
  private_subnet_cidrs = var.private_subnet_cidrs
  public_subnet_cidrs  = var.public_subnet_cidrs
  enable_nat_gateway   = var.enable_nat_gateway
  single_nat_gateway   = var.single_nat_gateway

  tags = local.common_tags
}

# ECR Module
module "ecr" {
  source = "./modules/ecr"

  repository_name      = var.ecr_repository_name
  image_tag_mutability = var.ecr_image_tag_mutability
  scan_on_push         = var.ecr_scan_on_push

  tags = local.common_tags
}

# EKS Module
module "eks" {
  source = "./modules/eks"

  cluster_name    = "${local.name}-cluster"
  cluster_version = var.cluster_version

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnet_ids

  node_groups = {
    main = {
      instance_types = var.node_instance_types
      min_size       = var.node_group_min_size
      max_size       = var.node_group_max_size
      desired_size   = var.node_group_desired_size
    }
  }

  # AWS Auth configuration
  aws_auth_roles = concat(
    # CI/CD role for GitHub Actions
    var.ci_cd_role_arn != "" ? [{
      rolearn  = var.ci_cd_role_arn
      username = "ci-cd"
      groups   = ["system:masters"]
    }] : [],
  )

  aws_auth_users = concat(
    # Local user for development
    var.local_user_arn != "" ? [{
      userarn  = var.local_user_arn
      username = "local-admin"
      groups   = ["system:masters"]
    }] : [],
  )

  tags = local.common_tags

  depends_on = [module.vpc]
}

# EKS Addons Module
module "addons" {
  count  = var.enable_addons ? 1 : 0
  source = "./modules/addons"

  cluster_name            = module.eks.cluster_name
  aws_region              = var.aws_region
  eks_oidc_provider_arn   = module.eks.oidc_provider_arn
  cluster_oidc_issuer_url = module.eks.cluster_oidc_issuer_url
  vpc_id                  = module.vpc.vpc_id

  # Addon configuration
  domain_name                          = var.domain_name
  certificate_email                    = var.certificate_email
  aws_load_balancer_controller_version = var.aws_load_balancer_controller_version
  external_dns_version                 = var.external_dns_version

  # Metrics Server configuration
  enable_metrics_server  = var.enable_metrics_server
  metrics_server_version = var.metrics_server_version

  tags = local.common_tags

  depends_on = [module.eks, module.vpc]
}
