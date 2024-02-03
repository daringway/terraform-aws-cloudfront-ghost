data "aws_route53_zone" "zone" {
  count        = local.dns_zone_name == null ? 0 : 1
  name         = local.dns_zone_name
  private_zone = false
}

resource "aws_route53_record" "dns" {
  for_each = local.dns_entries
  zone_id  = data.aws_route53_zone.zone[0].zone_id
  name     = each.key
  type     = "A"

  alias {
    name                   = aws_cloudfront_distribution.www.domain_name
    zone_id                = aws_cloudfront_distribution.www.hosted_zone_id
    evaluate_target_health = true
  }
}

resource "aws_route53_record" "dns_ipv6" {
  for_each = local.dns_entries
  zone_id  = data.aws_route53_zone.zone[0].zone_id
  name     = each.key
  type     = "AAAA" # Changed from "A" to "AAAA" for IPv6

  alias {
    name                   = aws_cloudfront_distribution.www.domain_name
    zone_id                = aws_cloudfront_distribution.www.hosted_zone_id
    evaluate_target_health = true
  }
}