module "aviatrix-create-aws-tgw-area1" {
  source = "./aws_tgw"

  region                = var.aws_region_1
  account_name          = var.aws_account_name
  firenet_domain        = var.firenet_domain # leave empty if no TGW FireNet, allows to skip domain creation
  egress_domain         = var.egress_domain  # leave empty if no TGW Egress FireNet, allows to skip domain creation
  inspected_domains     = var.inspected_domains
  not_inspected_domains = []
}

module "aviatrix-create-east-west-firenet-area1" {
  source = "./tgw_firenet"

  region             = var.aws_region_1
  account_name       = var.aws_account_name
  vpc_IP             = "10.6.0.0/16"
  vpc_name           = "FireNet-${var.aws_region_1}"
  avtx_gw_name       = "firenet-gw-${var.aws_region_1}"
  avtx_gw_size       = var.tgw_firenet_gw_size
  avtx_gw_ha         = true
  tgw_name           = module.aviatrix-create-aws-tgw-area1.tgw_id
  tgw_firenet_domain = var.firenet_domain
  attach             = true

#  depends_on = [module.aviatrix-create-egress-firenet-area1]
}

module "aviatrix-create-east-west-firewalls-area1" {
  source = "./pan_firewalls"

  firewall_names           = var.tgw_firewall_names
  key_name                 = aws_key_pair.ec2_key_region1.key_name
  cloud                    = "aws"
  byol                     = var.aws_byol
  pan_subscription         = var.aws_pan_subscription
  firewall_size            = var.tgw_firewall_size
  firenet_gw_name          = module.aviatrix-create-east-west-firenet-area1.avtx_gw_name
  vpc_id                   = module.aviatrix-create-east-west-firenet-area1.tvpc_id
  inspection_enabled       = true
  egress_enabled           = false
  iam_role                 = module.pan-bootstrap-buckets-area2.bootstrap_s3_role
  bootstrap_bucket_name    = module.pan-bootstrap-buckets-area2.bootstrap_bucket
  bootstrap_bucket_name_ha = module.pan-bootstrap-buckets-area2.bootstrap_bucket_ha
  management_subnet        = module.aviatrix-create-east-west-firenet-area1.firenet_mgmt_subnet
  egress_subnet            = module.aviatrix-create-east-west-firenet-area1.firenet_egress_subnet
  management_subnet_ha     = module.aviatrix-create-east-west-firenet-area1.firenet_mgmt_subnet_ha
  egress_subnet_ha         = module.aviatrix-create-east-west-firenet-area1.firenet_egress_subnet_ha
}

/*
module "aviatrix-create-egress-firenet-area1" {
  source = "./tgw_firenet"

  region             = var.aws_region_1
  account_name       = var.aws_account_name
  vpc_IP             = "10.7.0.0/16"
  vpc_name           = "Egress-FireNet-${var.aws_region_1}"
  avtx_gw_name       = "firenet-egress-gw-${var.aws_region_1}"
  avtx_gw_size       = var.tgw_firenet_gw_size
  avtx_gw_ha         = true
  tgw_name           = module.aviatrix-create-aws-tgw-area1.tgw_id
  tgw_firenet_domain = var.egress_domain
  inspection_enabled = false
  egress_enabled     = true
  attach             = true
}

module "aviatrix-create-egress-firewalls-area1" {
  source = "./pan_firewalls"

  firewall_names           = var.tgw_firewall_names
  key_name                 = aws_key_pair.ec2_key_region1.key_name
  cloud                    = "aws"
  byol                     = var.aws_byol
  pan_subscription         = var.aws_pan_subscription
  firewall_size            = var.tgw_firewall_size
  inspection_enabled       = true
  egress_enabled           = false
  firenet_gw_name          = module.aviatrix-create-egress-firenet-area1.avtx_gw_name
  vpc_id                   = module.aviatrix-create-egress-firenet-area1.tvpc_id
  iam_role                 = module.pan-bootstrap-buckets-area2.bootstrap_s3_role
  bootstrap_bucket_name    = module.pan-bootstrap-buckets-area2.bootstrap_bucket_egress
  bootstrap_bucket_name_ha = module.pan-bootstrap-buckets-area2.bootstrap_bucket_egress_ha
  management_subnet        = module.aviatrix-create-egress-firenet-area1.firenet_mgmt_subnet
  egress_subnet            = module.aviatrix-create-egress-firenet-area1.firenet_egress_subnet
  management_subnet_ha     = module.aviatrix-create-egress-firenet-area1.firenet_mgmt_subnet_ha
  egress_subnet_ha         = module.aviatrix-create-egress-firenet-area1.firenet_egress_subnet_ha
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
  firenet_gw_name          = module.aviatrix-create-transit-net-area-2.avtx_gw_name
  vpc_id                   = module.aviatrix-create-transit-net-area-2.tvpc_id
  iam_role                 = module.pan-bootstrap-buckets-area2.bootstrap_s3_role
  bootstrap_bucket_name    = module.pan-bootstrap-buckets-area2.bootstrap_bucket_egress
  bootstrap_bucket_name_ha = module.pan-bootstrap-buckets-area2.bootstrap_bucket_egress_ha
  management_subnet        = module.aviatrix-create-transit-net-area-2.firenet_mgmt_subnet
  egress_subnet            = module.aviatrix-create-transit-net-area-2.firenet_egress_subnet
  management_subnet_ha     = module.aviatrix-create-transit-net-area-2.firenet_mgmt_subnet_ha
  egress_subnet_ha         = module.aviatrix-create-transit-net-area-2.firenet_egress_subnet_ha
}
*/
###############################################

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
/*
resource "aws_key_pair" "ec2_key_region2" {
  provider = aws.region_2

  key_name   = "${var.avtx_key_name}_${replace(var.aws_region_2, "-", "_")}_ec2"
  public_key = tls_private_key.avtx_key.public_key_openssh
}
*/
