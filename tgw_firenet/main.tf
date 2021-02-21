resource "aviatrix_vpc" "security_vpc" {
  cloud_type           = 1
  account_name         = var.account_name
  region               = var.region
  name                 = var.vpc_name
  cidr                 = var.vpc_IP
  aviatrix_transit_vpc = false
  aviatrix_firenet_vpc = true
}

# Create an Aviatrix AWS Gateway
resource "aviatrix_transit_gateway" "firenet_gateway" {
  cloud_type               = 1
  account_name             = aviatrix_vpc.security_vpc.account_name
  vpc_reg                  = aviatrix_vpc.security_vpc.region
  gw_name                  = var.avtx_gw_name
  gw_size                  = var.avtx_gw_size
  vpc_id                   = aviatrix_vpc.security_vpc.vpc_id
  subnet                   = aviatrix_vpc.security_vpc.subnets[0].cidr
  ha_subnet                = var.avtx_gw_ha ? aviatrix_vpc.security_vpc.subnets[2].cidr : null
  ha_gw_size               = var.avtx_gw_ha ? var.avtx_gw_size : null
  enable_active_mesh       = true
  enable_transit_firenet   = true
  enable_hybrid_connection = false
}

/*
resource "aviatrix_firenet" "firewall_net" {
  vpc_id                               = aviatrix_vpc.security_vpc.vpc_id
  manage_firewall_instance_association = false
  inspection_enabled                   = var.inspection_enabled
  egress_enabled                       = var.egress_enabled

  depends_on = [aviatrix_transit_gateway.firenet_gateway]
}
*/
resource "aviatrix_aws_tgw_vpc_attachment" "tgw_FireNet_attachment" {
  count = var.attach ? 1 : 0

  tgw_name             = var.tgw_name
  region               = var.region
  security_domain_name = "Shared_Service_Domain"
  vpc_account_name     = var.account_name
  vpc_id               = aviatrix_vpc.security_vpc.vpc_id

  depends_on = [aviatrix_transit_gateway.firenet_gateway]
}
