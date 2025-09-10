# outputs.tf - Outputs for the addons module

output "aws_load_balancer_controller_role_arn" {
  description = "ARN of the AWS Load Balancer Controller IAM role"
  value       = aws_iam_role.load_balancer_controller.arn
}

output "external_dns_role_arn" {
  description = "ARN of the External DNS IAM role"
  value       = aws_iam_role.external_dns.arn
}

# ACM Certificate outputs
output "acm_certificate_arn" {
  description = "ARN of the main ACM certificate"
  value       = var.domain_name != "" ? aws_acm_certificate.main[0].arn : null
}

output "acm_certificate_domain" {
  description = "Domain name of the main ACM certificate"
  value       = var.domain_name != "" ? aws_acm_certificate.main[0].domain_name : null
}

output "acm_certificate_status" {
  description = "Status of the main ACM certificate"
  value       = var.domain_name != "" ? aws_acm_certificate.main[0].status : null
}
