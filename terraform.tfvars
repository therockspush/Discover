aws_profile            = "default"
controller_ip          = "X.X.X.X" # Created in another TF with the controller
shared_services_vpc_id = ""              # Created in another TF with the controller
aws_account_name       = "avtx_lab_demo" # Created in another TF with the controller
username               = "admin"
password               = "XXXXXXXXXX" # Created in another TF with the controller

aws_region_1 = "us-east-1"
aws_region_2 = "us-west-2"

avtx_key_name = "avtx_key"

#TGW info
firenet_domain      = "Firenet_Domain"
egress_domain       = "Egress_Domain"
inspected_domains   = ["Prod", "Dev"]
tgw_firenet_gw_size = "c5n.xlarge"

# Firewall info
tgw_firewall_names   = ["tgw-fw1"]  # List of FW names in zone A, firewalls in zone B will be created if avtx_gateway_ha set to true. They will have -ha extension
tgw_firewall_size    = "c5n.xlarge" # Check if supported in the region
aws_byol             = false
aws_pan_subscription = "Palo Alto Networks VM-Series Next-Generation Firewall Bundle 1 [VM-300]" # Not needed if byol = true
