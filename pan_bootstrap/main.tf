resource "aws_iam_role_policy" "pan_bootstrap_policy" {
  name = "pan-bootstrap-policy"
  role = aws_iam_role.pan_bootstrap_s3_role.id

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "s3:ListBucket"
            ],
            "Resource": [
                "arn:aws:s3:::*"
            ]
        },
        {
            "Effect": "Allow",
            "Action": [
                "s3:GetObject"
            ],
            "Resource": [
                "arn:aws:s3:::*"
          ]
        }
    ]
}
EOF
}

resource "aws_iam_role" "pan_bootstrap_s3_role" {
  name = "pan-bootstrap-s3-role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_instance_profile" "pan_bootstrap_s3_role" {
  name = "pan-bootstrap-s3-role"
  role = aws_iam_role.pan_bootstrap_s3_role.name
}


###########################################################
#  Bootstrap bucket without SNAT for East-West inspection

resource "aws_s3_bucket" "avtx_panvm_bootstrap" {
  bucket_prefix = "avtx-panvm-bootstrap-discover"
  acl           = "private"

  tags = {
    Name = "PAN VM Bootstrap"
  }
}

resource "aws_s3_bucket_object" "panvm_content" {
  bucket = aws_s3_bucket.avtx_panvm_bootstrap.id
  acl    = "private"
  key    = "content/"
  source = "/dev/null"
}

resource "aws_s3_bucket_object" "panvm_license" {
  bucket = aws_s3_bucket.avtx_panvm_bootstrap.id
  acl    = "private"
  key    = "license/"
  source = "/dev/null"
}

resource "aws_s3_bucket_object" "panvm_software" {
  bucket = aws_s3_bucket.avtx_panvm_bootstrap.id
  acl    = "private"
  key    = "software/"
  source = "/dev/null"
}

resource "aws_s3_bucket_object" "cfg_upload" {
  bucket = aws_s3_bucket.avtx_panvm_bootstrap.id
  key    = "config/init-cfg.txt"
  source = "${path.cwd}/pan_bootstrap//pan-bootstrap-cfg/init-cfg.txt"
  etag   = filemd5("${path.cwd}/pan_bootstrap//pan-bootstrap-cfg/init-cfg.txt")
}

resource "aws_s3_bucket_object" "bootstrap_upload" {
  bucket = aws_s3_bucket.avtx_panvm_bootstrap.id
  key    = "config/bootstrap.xml"
  source = "${path.cwd}/pan_bootstrap//pan-bootstrap-cfg/bootstrap.xml"
  etag   = filemd5("${path.cwd}/pan_bootstrap//pan-bootstrap-cfg/bootstrap.xml")
}

###########################################################
#  HA subnet bootstrap bucket without SNAT for East-West inspection
#  Needed for routing to correct subnet gateway during vendor inegration

resource "aws_s3_bucket" "avtx_panvm_bootstrap_ha" {
  bucket_prefix = "avtx-panvm-bootstrap-ha-discover"
  acl           = "private"

  tags = {
    Name = "PAN VM Bootstrap"
  }
}

resource "aws_s3_bucket_object" "panvm_content_ha" {
  bucket = aws_s3_bucket.avtx_panvm_bootstrap_ha.id
  acl    = "private"
  key    = "content/"
  source = "/dev/null"
}

resource "aws_s3_bucket_object" "panvm_license_ha" {
  bucket = aws_s3_bucket.avtx_panvm_bootstrap_ha.id
  acl    = "private"
  key    = "license/"
  source = "/dev/null"
}

resource "aws_s3_bucket_object" "panvm_software_ha" {
  bucket = aws_s3_bucket.avtx_panvm_bootstrap_ha.id
  acl    = "private"
  key    = "software/"
  source = "/dev/null"
}

resource "aws_s3_bucket_object" "cfg_upload_ha" {
  bucket = aws_s3_bucket.avtx_panvm_bootstrap_ha.id
  key    = "config/init-cfg.txt"
  source = "${path.cwd}/pan_bootstrap//pan-bootstrap-cfg/init-cfg.txt"
  etag   = filemd5("${path.cwd}/pan_bootstrap//pan-bootstrap-cfg/init-cfg.txt")
}

resource "aws_s3_bucket_object" "bootstrap_upload_ha" {
  bucket = aws_s3_bucket.avtx_panvm_bootstrap_ha.id
  key    = "config/bootstrap.xml"
  source = "${path.cwd}/pan_bootstrap//pan-bootstrap-cfg/bootstrap.xml"
  etag   = filemd5("${path.cwd}/pan_bootstrap//pan-bootstrap-cfg/bootstrap.xml")
}

###########################################################
#  Bootstrap bucket with SNAT for Egress
/*
resource "aws_s3_bucket" "avtx_panvm_bootstrap_egress" {
  bucket_prefix = "avtx-panvm-bootstrap-egress"
  acl           = "private"

  tags = {
    Name = "PAN VM Bootstrap"
  }
}

resource "aws_s3_bucket_object" "panvm_content_egress" {
  bucket = aws_s3_bucket.avtx_panvm_bootstrap_egress.id
  acl    = "private"
  key    = "content/"
  source = "/dev/null"
}

resource "aws_s3_bucket_object" "panvm_license_egress" {
  bucket = aws_s3_bucket.avtx_panvm_bootstrap_egress.id
  acl    = "private"
  key    = "license/"
  source = "/dev/null"
}

resource "aws_s3_bucket_object" "panvm_software_egress" {
  bucket = aws_s3_bucket.avtx_panvm_bootstrap_egress.id
  acl    = "private"
  key    = "software/"
  source = "/dev/null"
}

resource "aws_s3_bucket_object" "cfg_upload_egress" {
  bucket = aws_s3_bucket.avtx_panvm_bootstrap_egress.id
  key    = "config/init-cfg.txt"
  source = "${path.cwd}/pan_bootstrap//pan-bootstrap-cfg/init-cfg.txt"
  etag   = filemd5("${path.cwd}/pan_bootstrap//pan-bootstrap-cfg/init-cfg.txt")
}

resource "aws_s3_bucket_object" "bootstrap_upload_egress" {
  bucket = aws_s3_bucket.avtx_panvm_bootstrap_egress.id
  key    = "config/bootstrap.xml"
  source = "${path.cwd}/pan_bootstrap//pan-bootstrap-cfg/bootstrap_egress.xml"
  etag   = filemd5("${path.cwd}/pan_bootstrap//pan-bootstrap-cfg/bootstrap_egress.xml")
}

###########################################################
#  HA subnet bootstrap bucket with SNAT for Egress
#  Needed for routing to correct subnet gateway during vendor inegration

resource "aws_s3_bucket" "avtx_panvm_bootstrap_egress_ha" {
  bucket_prefix = "avtx-panvm-bootstrap-ha"
  acl           = "private"

  tags = {
    Name = "PAN VM Bootstrap"
  }
}

resource "aws_s3_bucket_object" "panvm_content_egress_ha" {
  bucket = aws_s3_bucket.avtx_panvm_bootstrap_egress_ha.id
  acl    = "private"
  key    = "content/"
  source = "/dev/null"
}

resource "aws_s3_bucket_object" "panvm_license_egress_ha" {
  bucket = aws_s3_bucket.avtx_panvm_bootstrap_egress_ha.id
  acl    = "private"
  key    = "license/"
  source = "/dev/null"
}

resource "aws_s3_bucket_object" "panvm_software_egress_ha" {
  bucket = aws_s3_bucket.avtx_panvm_bootstrap_egress_ha.id
  acl    = "private"
  key    = "software/"
  source = "/dev/null"
}

resource "aws_s3_bucket_object" "cfg_upload_egress_ha" {
  bucket = aws_s3_bucket.avtx_panvm_bootstrap_egress_ha.id
  key    = "config/init-cfg.txt"
  source = "${path.cwd}/pan_bootstrap//pan-bootstrap-cfg/init-cfg.txt"
  etag   = filemd5("${path.cwd}/pan_bootstrap//pan-bootstrap-cfg/init-cfg.txt")
}

resource "aws_s3_bucket_object" "bootstrap_upload_egress_ha" {
  bucket = aws_s3_bucket.avtx_panvm_bootstrap_egress_ha.id
  key    = "config/bootstrap.xml"
  source = "${path.cwd}/pan_bootstrap//pan-bootstrap-cfg/bootstrap_egress.xml"
  etag   = filemd5("${path.cwd}/pan_bootstrap//pan-bootstrap-cfg/bootstrap_egress.xml")
}
*/
