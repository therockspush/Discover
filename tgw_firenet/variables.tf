variable region {}

variable vpc_name {}
variable vpc_IP {
  description = "FireNet CIDR"
}

variable tgw_name {}
variable tgw_firenet_domain {}

variable account_name {
  description = "AWS account name configured in the controller"
}

variable avtx_gw_name {}
variable avtx_gw_size {}

variable avtx_gw_ha {
  type = bool
}

variable attach {}
