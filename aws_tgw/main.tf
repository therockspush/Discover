# Create an Aviatrix AWS TGW
resource "aviatrix_aws_tgw" "aws_tgw" {
  account_name                      = var.account_name
  aws_side_as_number                = var.tgw_asn
  manage_vpc_attachment             = false
  manage_transit_gateway_attachment = false
  region                            = var.region
  tgw_name                          = "OOB-TGW-${title(split("-", var.region)[1])}${split("-", var.region)[2]}"

  security_domains {
    security_domain_name = "Aviatrix_Edge_Domain"
    connected_domains    = compact(setunion(["Default_Domain", "Shared_Service_Domain", var.firenet_domain], var.inspected_domains, var.not_inspected_domains))
  }

  security_domains {
    security_domain_name = "Default_Domain"
    connected_domains = [
      "Aviatrix_Edge_Domain",
      "Shared_Service_Domain"
    ]
  }

  security_domains {
    security_domain_name = "Shared_Service_Domain"
    connected_domains = [
      "Aviatrix_Edge_Domain",
      "Default_Domain"
    ]
  }

  dynamic security_domains {
    for_each = var.egress_domain != "" ? tomap({ "domain" = var.egress_domain }) : {}

    content {
      security_domain_name = security_domains.value
      aviatrix_firewall    = true
      connected_domains    = setunion(var.inspected_domains, var.not_inspected_domains)
    }
  }

  dynamic security_domains {
    for_each = var.firenet_domain != "" ? tomap({ "domain" = var.firenet_domain }) : {}

    content {
      security_domain_name = security_domains.value
      aviatrix_firewall    = true
      connected_domains    = setunion(["Aviatrix_Edge_Domain"], var.inspected_domains)
    }
  }

  dynamic security_domains {
    for_each = var.inspected_domains

    content {
      security_domain_name = security_domains.value
      connected_domains    = compact(setunion(["Aviatrix_Edge_Domain", var.firenet_domain, var.egress_domain], setsubtract(var.inspected_domains, [security_domains.value])))
    }
  }

  dynamic security_domains {
    for_each = var.not_inspected_domains

    content {
      security_domain_name = security_domains.value
      connected_domains    = compact(setunion(["Aviatrix_Edge_Domain", var.egress_domain], setsubtract(var.not_inspected_domains, [security_domains.value])))
    }
  }
}

resource "aviatrix_aws_tgw_vpc_attachment" "default_route_vpc_attachment" {

  tgw_name             = aviatrix_aws_tgw.aws_tgw.tgw_name
  region               = var.region
  security_domain_name = "Shared_Service_Domain"
  vpc_account_name     = var.account_name
  vpc_id               = data.aws_vpc.NATGWVPC.id
  customized_route_advertisement = "0.0.0.0/0"

  depends_on = [aviatrix_aws_tgw.aws_tgw]
}

data "aws_vpc" "NATGWVPC" {

  filter {
    name = "tag:Name"
    values = [var.default_route_vpc]
  }
}