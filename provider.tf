provider "aviatrix" {
  username      = var.username
  password      = var.password
  controller_ip = var.controller_ip
  skip_version_validation = true

  version = "~> 2.1"
}

provider "aws" {
  region  = var.aws_region_1
  profile = var.aws_profile
  alias   = "region_1"
}

provider "aws" {
  region  = var.aws_region_2
  profile = var.aws_profile
  alias   = "region_2"
}

/*
provider "aws" {
  region  = var.aws_region_3
  profile = var.aws_profile
  alias   = "region_3"
}
*/

provider "local" {
  version = "~> 1.4"
}

provider "random" {
  version = "~> 2.2"
}

provider "tls" {
  version = "~> 2.1"
}
