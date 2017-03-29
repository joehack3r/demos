/*
  Terraform template to create a S3 bucket, assign CloudTrail policy to it, and create
  Global CloudTrail bucket with log file validation enabled.
*/

resource "aws_s3_bucket" "awslogs-tf" {
  bucket        = "my-globablly-unique-s3-bucket-name-for-tf"
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
                "arn:aws:s3:::${aws_s3_bucket.awslogs-tf.id}/*"
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
  name                          = "cloudtrail-via-terraform"
  s3_bucket_name                = "${aws_s3_bucket.awslogs-tf.id}"
  is_multi_region_trail         = true
  enable_log_file_validation    = true
  include_global_service_events = true

  depends_on = ["aws_s3_bucket_policy.cloudtrail-bucket-policy"]
}