
resource "aviatrix_vpc" "aws_transit" {
  cloud_type                = 1
  account_name              = var.account_name
  region                    = var.region
  name                      = var.aws_transit_name
  cidr                      = var.cidr
  aviatrix_transit_vpc      = var.firenet ? false : true
  aviatrix_firenet_vpc      = var.firenet ? true : false
  enable_private_oob_subnet = true
}


resource "aviatrix_aws_tgw_vpc_attachment" "transit_vpc_attachment" {
  tgw_name             = var.aws_transit_gw
  security_domain_name = "Shared_Service_Domain"
  region               = var.region
  vpc_account_name     = var.account_name
  vpc_id               = aviatrix_vpc.aws_transit.vpc_id
  subnets              = "${data.aws_subnet.selected_oob_subnet1.id} , ${data.aws_subnet.selected_oob_subnet2.id}"
  route_tables         = data.aws_route_table.TransitprivateRT.id
}

data "aws_subnet" "selected_oob_subnet1" {
  vpc_id = aviatrix_vpc.aws_transit.vpc_id

  filter {
    name   = "tag:Name"
    values = ["*Private-OOB-*1a"]
  }
}

data "aws_subnet" "selected_oob_subnet2" {
  vpc_id = aviatrix_vpc.aws_transit.vpc_id

  filter {
    name   = "tag:Name"
    values = ["*Private-OOB-*1b"]
  }
}

data "aws_route_table" "TransitprivateRT" {
  vpc_id = aviatrix_vpc.aws_transit.vpc_id

  filter {
    name   = "tag:Name"
    values = ["*Private-OOB*"]
  }
}

resource "aviatrix_transit_gateway" "transit_gateway_tvpc" {
  cloud_type   = 1
  vpc_reg      = var.region
  vpc_id       = aviatrix_vpc.aws_transit.vpc_id
  account_name = aviatrix_vpc.aws_transit.account_name
  gw_name      = "atgw-aws-${var.region}"
  insane_mode  = var.hpe
  gw_size      = var.avtx_gw_size
  #ha_gw_size   = var.avtx_gw_ha ? var.avtx_gw_size : null
  subnet             = cidrsubnet(aviatrix_vpc.aws_transit.cidr, 10, 5)
  #ha_subnet          = cidrsubnet(aviatrix_vpc.aws_transit.cidr, 10, 10)
  #insane_mode_az     = var.hpe ? data.aws_subnet.gw_az.availability_zone : null
  #ha_insane_mode_az  = var.avtx_gw_ha ? (var.hpe ? data.aws_subnet.hagw_az.availability_zone : null) : null
  enable_active_mesh = true
  connected_transit             = true
  enable_advertise_transit_cidr = false
  enable_transit_firenet        = true
  enable_private_oob            = true
  oob_availability_zone         = "us-east-1a"
  oob_management_subnet         = data.aws_subnet.selected_oob_subnet1.cidr_block

  depends_on = [aviatrix_aws_tgw_vpc_attachment.transit_vpc_attachment]
}




data "aws_subnet" "gw_az" {
  id = aviatrix_vpc.aws_transit.subnets[0].subnet_id
}

data "aws_subnet" "hagw_az" {
  id = aviatrix_vpc.aws_transit.subnets[2].subnet_id
}

