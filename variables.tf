
variable "tags" {
  type = map(string)
}

variable "public_fqdn" {
  type        = string
#   default     = "www"
  description = "The public hostname such as www in www.acme.com"
}

variable "acm_cert_arn" {
  type        = string
  description = "Override the default certification of *.DOMAIN"
}

variable "application" {
  type        = string
  description = "Application Name"
}

variable "cms_fqdn" {
  type        = string
  description = "The ghost FQDN hostname of the EC2 instance"
}