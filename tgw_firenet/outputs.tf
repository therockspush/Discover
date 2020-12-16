output "tvpc_id" {
  value = aviatrix_vpc.security_vpc.vpc_id
}

output "avtx_gw_name" {
  value = aviatrix_transit_gateway.firenet_gateway.gw_name
}

output "transit_gw_public_ip" {
  value = aviatrix_transit_gateway.firenet_gateway.eip
}

output "transit_gw_private_ip" {
  value = aviatrix_transit_gateway.firenet_gateway.private_ip
}

output "transit_hagw_public_ip" {
  value = aviatrix_transit_gateway.firenet_gateway.ha_eip
}

output "tvpc_cidr" {
  value = aviatrix_vpc.security_vpc.cidr
}

output "firenet_mgmt_subnet" {
  value = aviatrix_vpc.security_vpc.subnets[0].cidr
}

output "firenet_mgmt_subnet_ha" {
  value = aviatrix_vpc.security_vpc.subnets[2].cidr
}

output "firenet_egress_subnet" {
  value = aviatrix_vpc.security_vpc.subnets[1].cidr
}

output "firenet_egress_subnet_ha" {
  value = aviatrix_vpc.security_vpc.subnets[3].cidr
}

