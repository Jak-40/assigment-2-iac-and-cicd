# acm.tf - AWS Certificate Manager for automatic certificate management

# Data source to get Route53 hosted zone if domain is provided
data "aws_route53_zone" "selected" {
  count = var.domain_name != "" ? 1 : 0
  name  = var.domain_name
}

# Request ACM certificate for the domain and wildcard subdomain
resource "aws_acm_certificate" "main" {
  count = var.domain_name != "" ? 1 : 0

  domain_name               = var.domain_name
  subject_alternative_names = ["*.${var.domain_name}"]
  validation_method         = "DNS"

  # Ensure certificate recreation happens before deletion to avoid downtime
  lifecycle {
    create_before_destroy = true
  }

  tags = merge(var.tags, {
    Name = "${var.cluster_name}-certificate"
    Type = "wildcard"
  })
}

# Create DNS validation records in Route53
resource "aws_route53_record" "certificate_validation" {
  for_each = var.domain_name != "" ? {
    for dvo in aws_acm_certificate.main[0].domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  } : {}

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = data.aws_route53_zone.selected[0].zone_id
}

# Wait for certificate validation to complete
resource "aws_acm_certificate_validation" "main" {
  count = var.domain_name != "" ? 1 : 0

  certificate_arn         = aws_acm_certificate.main[0].arn
  validation_record_fqdns = [for record in aws_route53_record.certificate_validation : record.fqdn]

  timeouts {
    create = "5m"
  }
}
