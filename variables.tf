
variable "tags" {
  type = map(string)
}

variable "acm_cert_arn" {
  type        = string
  description = "Override the default certification of *.DOMAIN"
}

variable "application" {
  type        = string
  description = "Application Name"
}

