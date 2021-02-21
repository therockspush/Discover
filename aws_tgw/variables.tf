variable "region" {
  default = "us-east-1"
}

variable "account_name" {}

variable "tgw_asn" {
  default = 64512
}

variable "default_route_vpc" {}

variable "firenet_domain" {}
variable "egress_domain" {}

variable "inspected_domains" {}

variable "not_inspected_domains" {}
#variable "tvpc_id" {}
#variable "sec_vpc_id" {}
