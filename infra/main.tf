locals {
  tags = {
    project = var.project
    env     = "dev"
  }
}

resource "random_string" "suffix" {
  length  = 6
  upper   = false
  special = false
}

#####################
# AWS: S3 static site
#####################

resource "aws_s3_bucket" "site" {
  bucket = "${var.project}-site-${random_string.suffix.result}"
  tags   = local.tags
}

resource "aws_s3_bucket_ownership_controls" "site" {
  bucket = aws_s3_bucket.site.id
  rule { object_ownership = "BucketOwnerPreferred" }
}

resource "aws_s3_bucket_public_access_block" "site" {
  bucket                  = aws_s3_bucket.site.id
  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_website_configuration" "site" {
  bucket = aws_s3_bucket.site.id
  index_document { suffix = "index.html" }
  error_document { key    = "index.html" }
}

data "aws_iam_policy_document" "site_policy" {
  statement {
    sid     = "PublicReadGetObject"
    effect  = "Allow"
    actions = ["s3:GetObject"]
    principals { type = "AWS"; identifiers = ["*"] }
    resources = ["${aws_s3_bucket.site.arn}/*"]
  }
}

resource "aws_s3_bucket_policy" "public" {
  bucket = aws_s3_bucket.site.id
  policy = data.aws_iam_policy_document.site_policy.json
}

############################
# Azure: static website host
############################

resource "azurerm_resource_group" "rg" {
  name     = "${var.project}-rg-${random_string.suffix.result}"
  location = var.azure_location
  tags     = local.tags
}

resource "azurerm_storage_account" "sa" {
  name                     = replace("${var.project}sa${random_string.suffix.result}", "-", "")
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = azurerm_resource_group.rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  allow_nested_items_to_be_public = true
  tags                     = local.tags
}

resource "azurerm_storage_account_static_website" "static" {
  storage_account_id = azurerm_storage_account.sa.id
  index_document     = "index.html"
  error_404_document = "index.html"
}

############################
# Azure Traffic Manager (DR)
############################

resource "azurerm_traffic_manager_profile" "tm" {
  name                = "${var.project}-tm-${random_string.suffix.result}"
  resource_group_name = azurerm_resource_group.rg.name

  traffic_routing_method = "Priority"
  dns_config {
    relative_name = "${var.project}-${random_string.suffix.result}"
    ttl           = 30
  }

  monitor_config {
    protocol = "HTTP"
    port     = 80
    path     = "/health.txt"
  }

  tags = local.tags
}

# Endpoint 1: AWS S3 website (primary)
resource "azurerm_traffic_manager_external_endpoint" "aws_primary" {
  name                = "aws-primary"
  profile_name        = azurerm_traffic_manager_profile.tm.name
  resource_group_name = azurerm_resource_group.rg.name

  target       = aws_s3_bucket_website_configuration.site.website_endpoint
  endpoint_status = "Enabled"
  priority     = 1
}

# Endpoint 2: Azure static website (secondary)
resource "azurerm_traffic_manager_external_endpoint" "azure_secondary" {
  name                = "azure-secondary"
  profile_name        = azurerm_traffic_manager_profile.tm.name
  resource_group_name = azurerm_resource_group.rg.name

  target          = azurerm_storage_account_static_website.static.primary_web_host
  endpoint_status = "Enabled"
  priority        = 2
}

############################
# Optional: Route53 alias CNAME to TM DNS (if you own a domain)
############################

resource "aws_route53_record" "tm_alias" {
  count   = var.use_route53 ? 1 : 0
  zone_id = var.route53_zone_id
  name    = var.record_name
  type    = "CNAME"
  ttl     = 60
  records = [azurerm_traffic_manager_profile.tm.fqdn]
}
