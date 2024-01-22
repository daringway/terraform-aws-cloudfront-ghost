
# This is use when communicaiton with the ghost server.
resource "aws_cloudfront_function" "request" {
  name    = "${local.base_name}-viewer_request"
  runtime = "cloudfront-js-2.0"
  comment = "my function"
  publish = true
  code = templatefile("${path.module}/lambda/viewer_request.js", {
    redirect_from_list = local.cloudfront_aliases_string,
    redirect_to = local.public_fqdn,
    index_rewrite = false,
    append_slash = true
  })
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_cloudfront_distribution" "www" {
  enabled = true
  comment = local.base_name

  aliases = local.cloudfront_aliases

  viewer_certificate {
    acm_certificate_arn      = local.acm_cert_arn
    ssl_support_method       = "sni-only"
    minimum_protocol_version = "TLSv1"
  }

  restrictions {
    geo_restriction {
      restriction_type = "blacklist"
      locations        = ["CN"]
    }
  }

  // We always have the live server configured for ghost
  origin {
    origin_id   = local.server_origin_id
    domain_name = local.cms_fqdn

    custom_origin_config {
      http_port              = 80
      https_port             = 443
      origin_protocol_policy = "https-only"
      origin_ssl_protocols   = ["TLSv1.2"]  # Preferably use TLSv1.2 and TLSv1.3
    }

#    custom_header {
#      name  = "X-Forwarded-Host"
#      value = local.public_fqdn
#    }

    custom_header {
      name  = "X-Forwarded-Proto"
      value = "https"
    }

    connection_attempts = 3
    connection_timeout  = 5 // wait in seconds
  }

  // API
  origin {
    origin_id   = local.server_api_origin_id
    domain_name = local.cms_fqdn

    custom_origin_config {
      http_port              = 80
      https_port             = 443
      origin_protocol_policy = "https-only"
      origin_ssl_protocols   = ["TLSv1.2"]  # Preferably use TLSv1.2 and TLSv1.3
    }

#    custom_header {
#      name  = "X-Forwarded-Host"
#      value = local.cms_fqdn
#    }

    custom_header {
      name  = "X-Forwarded-Proto"
      value = "https"
    }

    connection_attempts = 3
    connection_timeout  = 10
  }

  ordered_cache_behavior {
    path_pattern = "/ghost/*"
    allowed_methods = [
      "GET",
      "HEAD",
      "OPTIONS",
      "PUT",
      "POST",
      "PATCH",
      "DELETE"
    ]
    cached_methods = [
      "HEAD",
      "GET"
    ]
    target_origin_id = local.server_api_origin_id

    forwarded_values {
      query_string = true
      headers      = ["Origin", "Referer", "User-Agent", "Host"]

      cookies {
        forward = "all"
      }
    }

    min_ttl                = 0
    default_ttl            = 0
    max_ttl                = 0
    compress               = false
    viewer_protocol_policy = "redirect-to-https"

  }

  default_cache_behavior {
    allowed_methods = [
      "GET",
      "HEAD",
      "OPTIONS",
      "PUT",
      "POST",
      "PATCH",
      "DELETE"
    ]
    cached_methods = [
      "HEAD",
      "GET"
    ]
    target_origin_id = local.origin_id

    forwarded_values {
      query_string = true
      headers      = ["Origin", "Referer", "User-Agent"]

      cookies {
        forward = "all"
      }
    }

    function_association {
      event_type   = "viewer-request"
      function_arn = aws_cloudfront_function.request.arn
    }
    lambda_function_association {
      event_type   = "origin-response"
      lambda_arn = aws_lambda_function.origin_response.qualified_arn
    }

    //    3600 1 hour 86400 is 1 day and
    min_ttl                = 0
    default_ttl            = 86400
    max_ttl                = 31536000
    compress               = false
    viewer_protocol_policy = "redirect-to-https"

  }

}



