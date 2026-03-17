
# ACM Certificate — only created if create_cert = true (requires Route53 hosted zone)
resource "aws_acm_certificate" "main" {
  count             = var.create_cert ? 1 : 0
  domain_name       = var.domain_name
  validation_method = "DNS"
  lifecycle { create_before_destroy = true }
  tags = { Name = "${var.project_name}-${var.environment}-cert" }
}

resource "aws_route53_record" "cert_validation" {
  count = var.create_cert ? 1 : 0
  for_each = {
    for dvo in aws_acm_certificate.main[0].domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      type   = dvo.resource_record_type
      record = dvo.resource_record_value
    }
  }
  zone_id = var.hosted_zone_id
  name    = each.value.name
  type    = each.value.type
  ttl     = 60
  records = [each.value.record]
}

resource "aws_acm_certificate_validation" "main" {
  count                   = var.create_cert ? 1 : 0
  certificate_arn         = aws_acm_certificate.main[0].arn
  validation_record_fqdns = [for record in aws_route53_record.cert_validation[0] : record.fqdn]
}
