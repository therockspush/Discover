# Create an Aviatrix Controller Private OOB
resource "aviatrix_controller_private_oob" "private_oob" {
  enable_private_oob = true
}

# Connecting Controlelr VPC to OOB TGW
/*
resource "aviatrix_aws_tgw_vpc_attachment" "ctrl_vpc_attachment" {
  tgw_name             = module.aviatrix-create-oob-aws-tgw-area1.tgw_id
  vpc_account_name     = var.aws_account_name
  region               = var.aws_region_1
  security_domain_name = "Shared_Service_Domain"
  vpc_id               = "vpc-0cd722e40abd8bad6"
}
*/

module "aviatrix-create-oob-aws-tgw-area1" {
  source = "./aws_tgw"

  region                = var.aws_region_1
  account_name          = var.aws_account_name
  firenet_domain        = var.firenet_domain # leave empty if no TGW FireNet, allows to skip domain creation
  egress_domain         = var.egress_domain  # leave empty if no TGW Egress FireNet, allows to skip domain creation
  inspected_domains     = var.inspected_domains
  not_inspected_domains = []
}

module "aviatrix-create-transit-net-area-1" {
  source = "./aws_transit"

  region           = var.aws_region_1
  account_name     = var.aws_account_name
  aws_transit_name = var.aws_transit_name_1
  avtx_gw_size     = var.aws_transit_gw_size
  cidr             = var.aws_transit_cidr_1
  aws_transit_gw   = module.aviatrix-create-oob-aws-tgw-area1.tgw_id
  hpe              = false
  firenet          = true

  providers = {
    aws = aws.region_1
  }
}

module "aviatrix-create-avtx-vpcs-area-1" {
  source = "./aws_vpcs"

  region         = var.aws_region_1
  account_name   = var.aws_account_name
  vpc_data       = var.vpc_data_region_1 # Determines number of VPCs created
  hpe            = false
  avtx_gw_size   = var.aws_spoke_gw_size
  avx_transit_gw = module.aviatrix-create-transit-net-area-1.avtx_gw_name
  tgw_name       = module.aviatrix-create-oob-aws-tgw-area1.tgw_id
  #  create_private_ec2 = var.create_private_ec2
  #  create_public_ec2  = var.create_public_ec2
  #  key_name           = aws_key_pair.ec2_key_region_1.key_name
  #  user_data          = data.template_file.ubuntu_server.template
  #  fixed_private_ip   = true
  #  private_ip = "32" # the last octet, module replaces xxx/xx in each subnet with this number
  #  ssh_addresses      = var.ssh_addresses

  providers = {
    aws = aws.region_1
  }
}

/*
module "aviatrix-create-firenet-area-1" {
  source = "./pan_firewalls"

  firewall_names           = var.avtx_firewall_names
  key_name                 = aws_key_pair.ec2_key_region_1.key_name
  cloud                    = "aws"
  byol                     = var.aws_byol
  pan_subscription         = var.aws_pan_subscription
  firewall_size            = var.avtx_firewall_size
  inspection_enabled       = true
  egress_enabled           = true
  firenet_gw_name          = module.aviatrix-create-transit-net-area-1.avtx_gw_name
  vpc_id                   = module.aviatrix-create-transit-net-area-1.tvpc_id
  iam_role                 = module.pan-bootstrap-buckets-area-2.bootstrap_s3_role
  bootstrap_bucket_name    = module.pan-bootstrap-buckets-area-2.bootstrap_bucket_egress
  bootstrap_bucket_name_ha = module.pan-bootstrap-buckets-area-2.bootstrap_bucket_egress_ha
  management_subnet        = module.aviatrix-create-transit-net-area-1.firenet_mgmt_subnet
  egress_subnet            = module.aviatrix-create-transit-net-area-1.firenet_egress_subnet
  management_subnet_ha     = module.aviatrix-create-transit-net-area-1.firenet_mgmt_subnet_ha
  egress_subnet_ha         = module.aviatrix-create-transit-net-area-1.firenet_egress_subnet_ha
}
*/


###############################################
/*
module "aviatrix-create-aws-tgw-area-2" {
  source = "./aws_tgw"

  region                = var.aws_region_2
  account_name          = var.aws_account_name
  firenet_domain        = "" # leave empty if no TGW FireNet, allows to skip domain creation
  egress_domain         = "" # leave empty if no TGW Egress FireNet, allows to skip domain creation
  inspected_domains     = [] # leave empty if no FireNet
  not_inspected_domains = []
}


module "aviatrix-create-firenet-area-2" {
  source = "./pan_firewalls"

  firewall_names           = var.tgw_firewall_names
  key_name                 = aws_key_pair.ec2_key_region2.key_name
  cloud                    = "aws"
  byol                     = var.aws_byol
  pan_subscription         = var.aws_pan_subscription
  firewall_size            = var.tgw_firewall_size
  inspection_enabled       = true
  egress_enabled           = true
  firenet_gw_name          = module.aviatrix-create-transit-net-area-1.avtx_gw_name
  vpc_id                   = module.aviatrix-create-transit-net-area-1.tvpc_id
  iam_role                 = module.pan-bootstrap-buckets-area2.bootstrap_s3_role
  bootstrap_bucket_name    = module.pan-bootstrap-buckets-area2.bootstrap_bucket_egress
  bootstrap_bucket_name_ha = module.pan-bootstrap-buckets-area2.bootstrap_bucket_egress_ha
  management_subnet        = module.aviatrix-create-transit-net-area-1.firenet_mgmt_subnet
  egress_subnet            = module.aviatrix-create-transit-net-area-1.firenet_egress_subnet
  management_subnet_ha     = module.aviatrix-create-transit-net-area-1.firenet_mgmt_subnet_ha
  egress_subnet_ha         = module.aviatrix-create-transit-net-area-1.firenet_egress_subnet_ha
}
*/
###############################################
/*
module "pan-bootstrap-buckets-area2" {
  source = "./pan_bootstrap"

  providers = {
    aws = aws.region_1
  }
}

resource "tls_private_key" "avtx_key" {
  algorithm = "RSA"
  rsa_bits  = 2048
}

resource "local_file" "avtx_priv_key" {
  content         = tls_private_key.avtx_key.private_key_pem
  filename        = "avtx_priv_key.pem"
  file_permission = "0400"
}

resource "local_file" "avtx_pub_key" {
  content         = tls_private_key.avtx_key.public_key_openssh
  filename        = "avtx_pub_key.pem"
  file_permission = "0666"
}

resource "aws_key_pair" "ec2_key_region1" {
  provider = aws.region_1

  key_name   = "${var.avtx_key_name}_${replace(var.aws_region_1, "-", "_")}_ec2"
  public_key = tls_private_key.avtx_key.public_key_openssh
}
*/
/*
resource "aws_key_pair" "ec2_key_region2" {
  provider = aws.region_2

  key_name   = "${var.avtx_key_name}_${replace(var.aws_region_2, "-", "_")}_ec2"
  public_key = tls_private_key.avtx_key.public_key_openssh
}
*/
