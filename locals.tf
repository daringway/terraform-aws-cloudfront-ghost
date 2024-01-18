
locals {
  application = var.application

  tags = merge(
    //    Default Tag Values
    {
      managed-by : "terraform",
    },
    //    User Tag Value
    var.tags,
    //    Fixed tags for module
    {
      Application : local.application,
    }
  )

  base_name = local.application
  alias_fqdns = var.alias_fqdns == null ? [format("%s.%s", "www", local.dns_zone_name)] : var.alias_fqdns

  cloudfront_aliases = flatten([[local.public_fqdn], local.alias_fqdns])
  cloudfront_aliases_string = "[${join(",", [for alias in local.alias_fqdns : format("\"%s\"", alias)])}]"

  dns_zone_name = var.dns_zone_name
  public_fqdn   = var.public_fqdn == null ? local.dns_zone_name : var.public_fqdn
  cms_fqdn      = var.cms_fqdn == null ? format("%s.%s", "ghost", local.dns_zone_name) : var.cms_fqdn


  dns_entries = local.dns_zone_name == null ? toset([]) : toset(flatten([local.public_fqdn, local.alias_fqdns]))

  server_origin_id     = "ghostServerOrigin"
  server_api_origin_id = "ghostServerAPIOrigin"
  origin_id            = local.server_origin_id

  acm_cert_arn = var.acm_cert_arn

  lambda_name = "${local.application}-origin-response"

}
