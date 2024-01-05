
variable "dns_zone_name" {
  type = string
  default = null
}

variable "alias_fqdns" {
  type = list(string)
  default = []
  description = "Alternate hostnames, that will be redirected to web_hostname"
}