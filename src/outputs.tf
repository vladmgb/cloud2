output "bucket_name" {
  description = "Name of the created bucket"
  value       = yandex_storage_bucket.my-bucket.bucket
}

output "bucket_domain" {
  description = "Bucket domain name"
  value       = yandex_storage_bucket.my-bucket.bucket_domain_name
}

output "image_url" {
  description = "Public URL of the uploaded image"
  value       = "https://${yandex_storage_bucket.my-bucket.bucket_domain_name}/${yandex_storage_object.my-image.key}"
}