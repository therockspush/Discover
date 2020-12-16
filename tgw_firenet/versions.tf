terraform {
  required_providers {
    aviatrix = {
      source = "aviatrixsystems/aviatrix"
    }
    local = {
      source = "hashicorp/local"
    }
    random = {
      source = "hashicorp/random"
    }
    tls = {
      source = "hashicorp/tls"
    }
  }
  required_version = ">= 0.13"
}
