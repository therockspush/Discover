variable byol {
  type = bool
}

variable pan_subscription {}

variable firewall_size {}

variable key_name {
  default = ""
}

variable firewall_names {
  description = "Provide a list of FW names in zone A, firewalls in zone B will be created if avtx_gateway_ha set to trus. They will have -ha extension "
  type        = set(string)
}
variable inspection_enabled {
  type = bool
}

variable egress_enabled {
  type = bool
}
variable firenet_gw_name {}
variable vpc_id {}
variable bootstrap_bucket_name {}
variable bootstrap_bucket_name_ha {}
variable iam_role {}
variable management_subnet {}
variable management_subnet_ha {}
variable egress_subnet {}
variable egress_subnet_ha {}
variable cloud {}
variable firewall_image_version {
  default = ""
}
