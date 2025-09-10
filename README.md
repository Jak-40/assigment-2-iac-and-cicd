# EKS Demo - Infrastructure as Code and CI/CD Solution

This project demonstrates a complete Infrastructure as Code (IaC) and CI/CD solution using modern DevOps practices. It provisions an Amazon EKS cluster using Terraform, deploys a containerized Node.js application, and implements **automated deployment via GitHub Actions** with no local setup required.

** Deployment Method: All infrastructure and application deployment is handled automatically through GitHub Actions CI/CD pipeline.**

## Architecture Overview

**Components:**
- **VPC Infrastructure**: Custom VPC with public/private subnets across 2 AZs
- **EKS Cluster**: Managed Kubernetes cluster with worker nodes  
- **ECR Repository**: Private container registry for Docker images
- **Load Balancer**: AWS Application Load Balancer with SSL/TLS
- **CI/CD Pipeline**: GitHub Actions with OIDC authentication
- **Application**: Node.js Express server with health checks and monitoring
- **Addons**: AWS Load Balancer Controller, External DNS, Cert-Manager

## Prerequisites

**Required:**
- GitHub account with repository access
- AWS account with admin permissions
- S3 bucket for Terraform state storage
- AWS OIDC Provider for GitHub Actions (see [OIDC Setup Guide](docs/aws-oidc-setup.md))

**Optional (for local development):**
- AWS CLI (v2.0+) - [Install Guide](https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2.html)
- kubectl (v1.28+) - [Install Guide](https://kubernetes.io/docs/tasks/tools/install-kubectl/)

## Quick Setup

### 1. Fork Repository and Configure Variables

```bash
# Fork this repository to your GitHub account
# Clone your forked repository
git clone https://github.com/YOUR_USERNAME/assignment-2-9-Sep.git
cd assignment-2-9-Sep

# Configure environment variables
cd terraform/environments
cp terraform.tfvars.example dev.tfvars
# Edit dev.tfvars with your AWS settings
```

**Key variables to set in `dev.tfvars`:**

```hcl
# Basic Configuration
aws_region   = "us-west-2"
environment  = "dev"
project_name = "eks-demo"

# EKS Configuration  
cluster_version = "1.32"
node_instance_types = ["t3.medium"]
node_group_desired_size = 2

# Domain (optional for HTTPS/DNS)
domain_name = "yourdomain.com"
certificate_email = "your-email@domain.com"

# IAM ARNs for EKS access
ci_cd_role_arn = "arn:aws:iam::ACCOUNT:role/GitHubActionsRole" 
local_user_arn = "arn:aws:iam::ACCOUNT:user/YourUser"
```

### 2. Configure GitHub Secrets

Add these secrets to your GitHub repository (Settings → Secrets and Variables → Actions):

```
AWS_ROLE_ARN: arn:aws:iam::ACCOUNT:role/GitHubActionsRole
AWS_REGION: us-west-2  
TF_STATE_BUCKET: your-terraform-state-bucket
```

### 3. Deploy Infrastructure via GitHub Actions

**Option A: Manual Trigger (Recommended for first deployment)**
1. Go to GitHub Actions tab in your repository
2. Select "Build, Push, and Deploy to EKS" workflow
3. Click "Run workflow"
4. Select environment (dev/staging/prod)
5. Click "Run workflow" to start deployment

**Option B: Push to Main Branch**
```bash
# Commit your configuration changes
git add terraform/environments/dev.tfvars
git commit -m "Configure infrastructure variables"
git push origin main

# This will automatically trigger the CI/CD pipeline
```

### 4. Monitor Deployment

1. Go to GitHub Actions tab to monitor progress
2. Infrastructure deployment takes 15-20 minutes
3. Application deployment takes 5-10 minutes
4. Check deployment status and logs in the Actions output

### 5. Access Your Application

After successful deployment:
1. Check GitHub Actions summary for application URLs
2. Access via Load Balancer URL provided in the deployment output
3. If domain is configured: `https://demo-app.yourdomain.com`

## Project Structure

```
terraform/
├── main.tf                 # Main infrastructure
├── variables.tf            # Input variables  
├── outputs.tf             # Output values
├── environments/
│   ├── dev.tfvars         # Development config
│   └── terraform.tfvars.example
└── modules/
    ├── vpc/               # VPC networking
    ├── eks/               # EKS cluster
    ├── ecr/               # Container registry
    └── addons/            # EKS addons

app/
├── src/index.js           # Node.js application
├── k8s/                   # Kubernetes manifests
├── Dockerfile             # Container definition
└── package.json           # Dependencies

.github/workflows/
└── deploy.yml             # CI/CD pipeline
```

## 🔧 Configuration Options

### Terraform Variables

**Core Infrastructure:**
| Variable | Description | Default | Example |
|----------|-------------|---------|---------|
| `aws_region` | AWS region | `us-west-2` | `us-east-1` |
| `environment` | Environment name | `dev` | `prod`, `staging` |
| `cluster_version` | Kubernetes version | `1.28` | `1.32` |
| `vpc_cidr` | VPC network range | `10.0.0.0/16` | `10.1.0.0/16` |

**Node Configuration:**
| Variable | Description | Default | Example |
|----------|-------------|---------|---------|
| `node_instance_types` | EC2 instance types | `["t3.medium"]` | `["t3.large"]` |
| `node_group_desired_size` | Number of nodes | `2` | `3` |
| `node_group_min_size` | Minimum nodes | `1` | `2` |
| `node_group_max_size` | Maximum nodes | `4` | `10` |

**Optional Features:**
| Variable | Description | Default | Example |
|----------|-------------|---------|---------|
| `enable_addons` | Enable EKS addons | `true` | `false` |
| `domain_name` | Custom domain | `""` | `myapp.com` |
| `single_nat_gateway` | Use single NAT | `true` | `false` |

### Environment Variables

**Application Runtime:**
| Variable | Description | Default |
|----------|-------------|---------|
| `NODE_ENV` | Environment mode | `production` |
| `PORT` | Application port | `8080` |
| `APP_VERSION` | App version | `1.0.0` |

## API Endpoints

| Endpoint | Method | Description |
|----------|--------|-------------|
| `/` | GET | Application info and system stats |
| `/health` | GET | Health check (liveness probe) |
| `/ready` | GET | Readiness check |
| `/api/info` | GET | API information |
| `/api/version` | GET | Version details |

##  Troubleshooting

### Common Issues

**1. GitHub Actions Infrastructure Deployment Fails**
- Check GitHub Secrets are configured correctly
- Verify AWS OIDC role has required permissions
- Ensure S3 backend bucket exists and is accessible
- Review Terraform plan output in Actions logs

**2. GitHub Actions Application Deployment Fails**
- Verify ECR repository exists (created by infrastructure step)
- Check EKS cluster is accessible
- Review container build logs for issues
- Ensure Kubernetes manifests are valid

**3. GitHub Actions Authentication Issues**
```
Error: could not retrieve caller identity
```
- Verify `AWS_ROLE_ARN` secret is correct
- Check OIDC provider is configured properly
- Ensure GitHub repository is allowed to assume the role

**4. Application Not Accessible**
- Check Load Balancer is provisioned (takes 5-10 minutes)
- Verify DNS records if using custom domain
- Check security groups allow traffic on port 80/443
- Review ingress controller logs in GitHub Actions output

**5. Workflow Fails on First Run**
- Infrastructure must be deployed before application
- Use manual trigger to deploy infrastructure first
- Subsequent pushes will update application only

### Debugging via GitHub Actions

**View Deployment Status:**
1. Go to GitHub Actions tab
2. Click on latest workflow run
3. Expand job steps to see detailed logs
4. Check "Deployment Summary" for service URLs

**Re-run Failed Jobs:**
1. Click "Re-run failed jobs" in Actions
2. Select specific environment if needed
3. Monitor logs for specific error messages

### Local Debugging (Optional)

If you need to debug locally after GitHub Actions deployment:

```bash
# Configure kubectl to access deployed cluster
aws eks update-kubeconfig --region us-west-2 --name eks-demo-dev-cluster

# Check cluster status
kubectl get nodes
kubectl get pods -l app=demo-app

# View application logs
kubectl logs -l app=demo-app --tail=100
```

## Cleanup Instructions

**⚠️ Important: To avoid AWS charges**

### Option A: Destroy via GitHub Actions (Recommended)

**Manual Workflow Trigger:**
1. Go to GitHub Actions tab
2. Select "Build, Push, and Deploy to EKS" workflow  
3. Click "Run workflow"
4. Select "destroy" for the action input (if available)
5. Monitor the destruction process

**Local Terraform Destroy:**
If you have local access configured:
```bash
cd terraform
terraform destroy -var-file="environments/dev.tfvars"
```

### Option B: Manual AWS Console Cleanup

1. **Delete EKS Cluster:**
   - Go to AWS EKS Console
   - Delete the cluster: `eks-demo-dev-cluster`

2. **Delete ECR Repository:**
   - Go to AWS ECR Console
   - Delete repository: `demo-app`

3. **Delete VPC and Resources:**
   - Go to AWS VPC Console
   - Delete VPC tagged with `Project: eks-demo`

### Verify Cleanup

Check these AWS services have no remaining resources:
- EKS Clusters
- ECR Repositories  
- VPCs with project tags
- Load Balancers
- NAT Gateways

## Contributing

1. Fork the repository
2. Create a feature branch: `git checkout -b feature/new-feature`
3. Commit changes: `git commit -am 'Add new feature'`
4. Push to the branch: `git push origin feature/new-feature`
5. Submit a pull request

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

**Architecture Features:**
- ✅ **Fully automated deployment via GitHub Actions** - No local tools required
- ✅ **OIDC Authentication** - Secure, keyless AWS access from GitHub
- ✅ **Infrastructure as Code** - Modular Terraform with remote state
- ✅ **Multi-environment support** - Dev/staging/prod via workflow dispatch
- ✅ **Container security** - Non-root user, image scanning, security contexts
- ✅ **Production-ready EKS** - Auto-scaling, load balancing, health checks
- ✅ **Cost-optimized** - Single NAT gateway, efficient resource allocation
- ✅ **Observability ready** - Monitoring, logging, and metrics collection

This project demonstrates modern DevOps practices with **GitHub Actions-driven** Infrastructure as Code, containerization, and automated deployment pipelines.
