output "s3_object_url" {
    value = "${aws_s3_bucket.bucket.bucket_domain_name}/${aws_s3_object.object.id}"
}
