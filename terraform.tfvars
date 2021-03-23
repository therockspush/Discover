aws_profile            = ""
controller_ip          = ""
shared_services_vpc_id = ""
aws_account_name       = ""
username               = "admin"
password               = ""

default_route_vpc = "DefaultNATVPCNVa"

aws_region_1 = "us-east-1"
aws_region_2 = "us-west-2"

avtx_key_name = "avtx_key"

#TGW info
firenet_domain      = ""
egress_domain       = ""
inspected_domains   = []
tgw_firenet_gw_size = "c5n.xlarge"

# Firewall info
# List of FW names in zone A, firewalls in zone B will be created if avtx_gateway_ha set to true. They will have -ha extension
tgw_firewall_names   = ["tgw-fw1","tgw-fw2"]
avtx_firewall_size    = "c5n.xlarge"
aws_byol             = false
aws_pan_subscription = "Palo Alto Networks VM-Series Next-Generation Firewall Bundle 1 [VM-300]" # Not needed if byol = true

# Aviatrix spoke VPCs - as many VPCs as you want, adding region requires adding a module in main.tf
vpc_data_region_1 = {
  vpc1 = {
    name = "VPC1-East1"
    cidr = "10.4.0.0/24"
  }
  vpc2 = {
    name = "VPC2-East1"
    cidr = "10.5.0.0/24"
  }
}

#Transit info
aws_transit_name_1  = "AWS-Edge-East1"
aws_transit_cidr_1  = "10.8.0.0/23"
aws_transit_gw_size = "c5n.xlarge"
aws_spoke_gw_size   = "t3.small"
