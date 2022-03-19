#PANW Bootstrap config

#Random string for unique s3 bucket
resource "random_string" "bucket" {
  length  = 8
  special = false
  upper   = false
}

resource "aws_s3_bucket" "bootstrap" {
  bucket = "panw-bootstrap-${random_string.bucket.result}"  
}

resource "aws_s3_bucket_public_access_block" "bootstrap" {
  bucket = aws_s3_bucket.bootstrap.id

  block_public_acls       = true
  ignore_public_acls      = true
  block_public_policy     = true
  restrict_public_buckets = true
}

resource "aws_s3_object" "folder_config" {
  bucket = aws_s3_bucket.bootstrap.id  
  key    = "config/"
  source = "/dev/null"
}

resource "aws_s3_object" "folder_content" {
  bucket = aws_s3_bucket.bootstrap.id  
  key    = "content/"
  source = "/dev/null"
}

resource "aws_s3_object" "folder_license" {
  bucket = aws_s3_bucket.bootstrap.id  
  key    = "license/"
  source = "/dev/null"
}

resource "aws_s3_object" "folder_software" {
  bucket = aws_s3_bucket.bootstrap.id  
  key    = "software/"
  source = "/dev/null"
}

resource "aws_s3_object" "xml" {
  bucket = aws_s3_bucket.bootstrap.id
  key    = "config/bootstrap.xml"
  source = "bootstrap/bootstrap.xml"
}

resource "aws_s3_object" "init" {
  bucket = aws_s3_bucket.bootstrap.id
  key    = "config/init-cfg.txt"
  source = "bootstrap/init-cfg.txt"
}

#Create IAM role and policy for the FW instance to access the bucket.
resource "aws_iam_role" "bootstrap" {
  name = "bootstrap-${random_string.bucket.result}"
  assume_role_policy = jsonencode(
    {
      "Version" : "2012-10-17",
      "Statement" : [
        {
          "Effect" : "Allow",
          "Principal" : {
            "Service" : "ec2.amazonaws.com"
          },
          "Action" : "sts:AssumeRole"
        }
      ]
    }
  )
}


resource "aws_iam_policy" "bootstrap" {
  name = "bootstrap-${random_string.bucket.result}"
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Action" : [
          "s3:ListBucket"
        ],
        "Resource" : [
          "${aws_s3_bucket.bootstrap.arn}"
        ]
      },
      {
        "Effect" : "Allow",
        "Action" : [
          "s3:GetObject"
        ],
        "Resource" : [
          "${aws_s3_bucket.bootstrap.arn}/*"
        ]
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "policy_role" {
  role       = aws_iam_role.bootstrap.name
  policy_arn = aws_iam_policy.bootstrap.arn
}

resource "aws_iam_instance_profile" "instance_role" {
  name = "bootstrap-${random_string.bucket.result}" #Needs to match the iam_role_name for the Aviatrix controller to pick it up.
  role = aws_iam_role.bootstrap.name
}
