output "vpcs" {
  value = aviatrix_vpc.aws_vpc
}

/*
output "public_sg_ids" {
  value = values(aws_security_group.public)[*].id
}
*/
output "vpc_ids" {
  value = values(aviatrix_vpc.aws_vpc)[*].vpc_id
}

output "subnets_cidr" {
  value = values(aviatrix_vpc.aws_vpc)[*].subnets[*].cidr
}

output "subnets_id" {
  value = values(aviatrix_vpc.aws_vpc)[*].subnets[*].subnet_id
}

/*
output "public_subnet_1_id" {
  value = values(aviatrix_vpc.aws_vpc)[*].subnets[length(data.aws_availability_zones.az_available.names)].subnet_id
}

output "public_subnet_2_id" {
  value = values(aviatrix_vpc.aws_vpc)[*].subnets[length(data.aws_availability_zones.az_available.names) + 1].subnet_id
}

output "public_subnet_1_cidr" {
  value = values(aviatrix_vpc.aws_vpc)[*].subnets[length(data.aws_availability_zones.az_available.names)].cidr
}

output "public_subnet_2_cidr" {
  value = values(aviatrix_vpc.aws_vpc)[*].subnets[length(data.aws_availability_zones.az_available.names) + 1].cidr
}
*/
