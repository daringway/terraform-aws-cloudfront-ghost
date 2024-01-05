
variable "dns_zone_name" {
  type = string
  default = null
}

variable "public_fqdn" {
  type        = string
   default    = null
  description = "The public hostname such as www in www.acme.com"
}

variable "alias_fqdns" {
  type = list(string)
  default = null
  description = "Alternate hostnames, that will be redirected to web_hostname"
}

variable "cms_fqdn" {
  type        = string
  default     = null
  description = "The ghost FQDN hostname of the EC2 instance"
}