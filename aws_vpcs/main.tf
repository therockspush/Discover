data "aws_availability_zones" "az_available" {}

resource "aviatrix_vpc" "aws_vpc" {
  for_each = var.vpc_data

  cloud_type                = 1
  account_name              = var.account_name
  region                    = var.region
  name                      = each.value.name
  cidr                      = each.value.cidr
  subnet_size               = 28
  num_of_subnet_pairs       = 2
  aviatrix_transit_vpc      = false
  aviatrix_firenet_vpc      = false
  enable_private_oob_subnet = true
}

resource "aviatrix_aws_tgw_vpc_attachment" "spoke_vpc_attachment" {
  for_each = var.vpc_data

  tgw_name             = var.tgw_name
  vpc_account_name     = var.account_name
  region               = var.region
  security_domain_name = "Shared_Service_Domain"
  vpc_id               = aviatrix_vpc.aws_vpc[each.key].vpc_id
  subnets              = data.aws_subnet.spokeselected1[each.key].id
  route_tables         = data.aws_route_table.spokeprivateRT[each.key].id

  depends_on = [aviatrix_vpc.aws_vpc]
}

data "aws_subnet" "spokeselected1" {
  for_each = var.vpc_data

  vpc_id = aviatrix_vpc.aws_vpc[each.key].vpc_id

  filter {
    name   = "tag:Name"
    values = ["*Private-OOB*-1a"]
  }
}

data "aws_subnet" "spokeselected2" {
  for_each = var.vpc_data

  vpc_id = aviatrix_vpc.aws_vpc[each.key].vpc_id

  filter {
    name   = "tag:Name"
    values = ["*Private-OOB-*1b"]
  }
}

data "aws_route_table" "spokeprivateRT" {
  for_each = var.vpc_data

  vpc_id = aviatrix_vpc.aws_vpc[each.key].vpc_id

  filter {
    name   = "tag:Name"
    values = ["*Private-OOB*"]
  }
}


resource "aviatrix_spoke_gateway" "avtx_spoke_gw" {
  for_each = var.vpc_data

  cloud_type        = 1
  account_name      = var.account_name
  gw_name           = "${lower(each.value.name)}-gw"
  vpc_id            = aviatrix_vpc.aws_vpc[each.key].vpc_id
  vpc_reg           = var.region
  insane_mode       = var.hpe
  #ha_gw_size        = var.avtx_gw_ha ? var.avtx_gw_size : null
  gw_size           = var.avtx_gw_size
  subnet            = cidrsubnet(aviatrix_vpc.aws_vpc[each.key].cidr, 10, 5)
  #ha_subnet         = cidrsubnet(aviatrix_vpc.aws_vpc[each.key].cidr, 10, 10)
  #insane_mode_az    = var.hpe ? data.aws_availability_zones.az_available.names[0] : null
  #ha_insane_mode_az = var.avtx_gw_ha ? (var.hpe ? data.aws_availability_zones.az_available.names[1] : null) : null
  transit_gw         = var.avx_transit_gw
  enable_active_mesh    = true
  enable_private_oob    = true
  oob_availability_zone = "us-east-1a"
  oob_management_subnet = data.aws_subnet.spokeselected1[each.key].cidr_block

  depends_on = [aviatrix_aws_tgw_vpc_attachment.spoke_vpc_attachment]
}



resource "aviatrix_transit_firenet_policy" "test_transit_firenet_policy1" {
  transit_firenet_gateway_name = var.avx_transit_gw
  inspected_resource_name      = "SPOKE:vpc1-east1-gw"

  depends_on                   = [aviatrix_spoke_gateway.avtx_spoke_gw]
  
}