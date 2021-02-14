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
  subnets              = "${data.aws_subnet.spokeselected1[each.key].id} , ${data.aws_subnet.spokeselected2[each.key].id}"
  route_tables         = data.aws_route_table.spokeprivateRT[each.key].id
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
  ha_gw_size        = var.avtx_gw_ha ? var.avtx_gw_size : null
  gw_size           = var.avtx_gw_size
  subnet            = cidrsubnet(aviatrix_vpc.aws_vpc[each.key].cidr, 10, 5)
  ha_subnet         = cidrsubnet(aviatrix_vpc.aws_vpc[each.key].cidr, 10, 10)
  insane_mode_az    = var.hpe ? data.aws_availability_zones.az_available.names[0] : null
  ha_insane_mode_az = var.avtx_gw_ha ? (var.hpe ? data.aws_availability_zones.az_available.names[1] : null) : null
  transit_gw         = var.avx_transit_gw
  enable_active_mesh    = true
  enable_private_oob    = true
  oob_availability_zone = "us-east-1a"
  oob_management_subnet = data.aws_subnet.spokeselected1[each.key].cidr_block

  depends_on = [aviatrix_aws_tgw_vpc_attachment.spoke_vpc_attachment]
}


/*
data "aws_ami" "ubuntu_server" {
  most_recent = true
  owners      = ["099720109477"]

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-bionic-18.04-amd64-server-*"]
  }
  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

resource "aws_instance" "test_instance_public" {
  for_each = var.create_public_ec2 ? var.vpc_data : {}

  key_name                    = var.key_name
  ami                         = var.ami == "" ? data.aws_ami.ubuntu_server.id : var.ami
  instance_type               = var.instance_type
  subnet_id                   = aviatrix_vpc.aws_vpc[each.key].subnets[length(data.aws_availability_zones.az_available.names)].subnet_id
  vpc_security_group_ids      = [aws_security_group.public[each.key].id]
  associate_public_ip_address = true
  user_data                   = var.user_data

  tags = {
    Name = "${each.value.name}-public-ubuntu"
  }
}

resource "aws_instance" "test_instance_private" {
  for_each = var.create_private_ec2 ? var.vpc_data : {}

  key_name                    = var.key_name
  ami                         = var.ami == "" ? data.aws_ami.ubuntu_server.id : var.ami
  instance_type               = var.instance_type
  subnet_id                   = aviatrix_vpc.aws_vpc[each.key].subnets[1].subnet_id
  vpc_security_group_ids      = [aws_security_group.private[each.key].id]
  associate_public_ip_address = false
  user_data                   = var.user_data
  private_ip                  = var.fixed_private_ip ? join("", [regex("([\\d+\\.]+)(\\.\\d+/\\d+)", aviatrix_vpc.aws_vpc[each.key].subnets[1].cidr)[0], ".", var.private_ip]) : null

  tags = {
    Name = "${each.value.name}-private-ubuntu"
  }
}

resource "aws_security_group" "public" {
  for_each = var.vpc_data

  name   = "${aviatrix_vpc.aws_vpc[each.key].name}-All-RFC1918-and-ssh"
  vpc_id = aviatrix_vpc.aws_vpc[each.key].vpc_id
  tags = {
    Name = "${aviatrix_vpc.aws_vpc[each.key].name}-All-RFC1918-and-ssh"
  }
}

resource "aws_security_group_rule" "egress_all" {
  for_each = var.vpc_data

  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.public[each.key].id
}

resource "aws_security_group_rule" "ingress_all" {
  for_each = var.vpc_data

  type              = "ingress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["10.0.0.0/8", "172.16.0.0/12", "192.168.0.0/16"]
  security_group_id = aws_security_group.public[each.key].id
}

resource "aws_security_group_rule" "ingress_ssh" {
  for_each = length(var.ssh_addresses) == 0 ? {} : var.vpc_data

  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = var.ssh_addresses
  security_group_id = aws_security_group.public[each.key].id
}


resource "aws_security_group" "private" {
  for_each = var.vpc_data

  name   = "${aviatrix_vpc.aws_vpc[each.key].name}-All-RFC1918"
  vpc_id = aviatrix_vpc.aws_vpc[each.key].vpc_id
  tags = {
    Name = "${aviatrix_vpc.aws_vpc[each.key].name}-All-RFC1918"
  }
}

resource "aws_security_group_rule" "egress_all_private" {
  for_each = var.vpc_data

  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.private[each.key].id
}

resource "aws_security_group_rule" "ingress_all_private" {
  for_each = var.vpc_data

  type              = "ingress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["10.0.0.0/8", "172.16.0.0/12", "192.168.0.0/16"]
  security_group_id = aws_security_group.private[each.key].id
}
*/
