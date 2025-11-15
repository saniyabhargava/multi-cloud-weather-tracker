variable "project"            { type = string  default = "mc-weather" }
variable "aws_region"         { type = string  default = "eu-west-1" }
variable "azure_location"     { type = string  default = "westeurope" }

variable "azure_subscription_id" { type = string }
variable "azure_tenant_id"       { type = string }

# Optional Route53 custom domain
variable "use_route53"       { type = bool   default = false }
variable "route53_zone_id"   { type = string default = "" } # e.g. Z123456789
variable "record_name"       { type = string default = "weather" } # subdomain (weather.example.com)


variable "oci_region" {
  description = "OCI region where the bucket is created (e.g., eu-frankfurt-1)"
  type        = string
}

variable "oci_namespace" {
  description = "OCI Object Storage namespace (from Tenancy details)"
  type        = string
}

variable "oci_compartment_ocid" {
  description = "OCI Compartment OCID where the bucket will live"
  type        = string
}
