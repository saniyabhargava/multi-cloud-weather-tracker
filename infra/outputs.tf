output "aws_s3_website_endpoint" {
  value = aws_s3_bucket_website_configuration.site.website_endpoint
}

output "azure_static_website_endpoint" {
  value = azurerm_storage_account_static_website.static.primary_web_host
}

output "traffic_manager_dns" {
  value = azurerm_traffic_manager_profile.tm.fqdn
}

output "route53_record" {
  value       = var.use_route53 ? "${var.record_name} (in Route53 zone ${var.route53_zone_id})" : "disabled"
  description = "Optional custom DNS via Route53"
}

# Public URL to index.html in OCI Object Storage
output "oci_site_url" {
  value = "https://objectstorage.${var.oci_region}.oraclecloud.com/n/${var.oci_namespace}/b/${oci_objectstorage_bucket.site.name}/o/index.html"
  description = "Direct URL to the Oracle Cloud (OCI) hosted version of the site"
}
