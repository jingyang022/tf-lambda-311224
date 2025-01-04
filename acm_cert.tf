# Step 1: Request an ACM Certificate
resource "aws_acm_certificate" "mycert_acm" {
  domain_name       = "yap201224.sctp-sandbox.com"
  validation_method = "DNS"

  #provider = aws.virginia

  lifecycle {
    create_before_destroy = true
  }
}

# Step 2: Create Route 53 DNS Record for Validation
resource "aws_route53_record" "cert_validation_record" {
  for_each = {
    for dvo in aws_acm_certificate.mycert_acm.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = data.aws_route53_zone.sctp_zone.zone_id
}

#Step 3: Handle Certificate Validation
resource "aws_acm_certificate_validation" "cert_validation" {

  #provider = aws.virginia

  timeouts {
    create = "5m"
  }
  
  certificate_arn         = aws_acm_certificate.mycert_acm.arn
  validation_record_fqdns = [for record in aws_route53_record.cert_validation_record : record.fqdn]
}