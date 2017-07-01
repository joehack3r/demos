/*
  Terraform template to create a S3 bucket, assign CloudTrail policy to it, and create
  Global CloudTrail bucket with log file validation enabled.
*/

data "aws_caller_identity" "current" {}

variable "cloudtrail-bucket-name" {
  description = "S3 bucket to create for storing CloudTrail logs."
  type        = "string"
  default     = "my-globablly-unique-s3-bucket-name-for-tf"
}

resource "aws_s3_bucket" "awslogs-tf" {
  bucket        = "${var.cloudtrail-bucket-name}"
  force_destroy = true
}

resource "aws_s3_bucket_policy" "cloudtrail-bucket-policy" {
  bucket = "${aws_s3_bucket.awslogs-tf.id}"

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "AWSCloudTrailAclCheck",
            "Effect": "Allow",
            "Principal": {
                "Service": "cloudtrail.amazonaws.com"
            },
            "Action": [
                "s3:GetBucketAcl"
            ],
            "Resource": [
                "arn:aws:s3:::${aws_s3_bucket.awslogs-tf.id}"
            ]
        },
        {
            "Sid": "AWSCloudTrailWrite",
            "Effect": "Allow",
            "Principal": {
                "Service": "cloudtrail.amazonaws.com"
            },
            "Action": [
                "s3:PutObject"
            ],
            "Resource": [
                "arn:aws:s3:::${aws_s3_bucket.awslogs-tf.id}/AWSLogs/${data.aws_caller_identity.current.account_id}/*"
            ],
            "Condition": {
                "StringEquals": {
                    "s3:x-amz-acl": "bucket-owner-full-control"
                }
            }
        }
    ]
}
EOF
}

resource "aws_cloudtrail" "cloudtrail-tf" {
  depends_on = ["aws_s3_bucket_policy.cloudtrail-bucket-policy"]

  name                          = "cloudtrail-via-terraform"
  s3_bucket_name                = "${aws_s3_bucket.awslogs-tf.id}"
  enable_log_file_validation    = true
  enable_logging                = true
  include_global_service_events = true
  is_multi_region_trail         = true
}
