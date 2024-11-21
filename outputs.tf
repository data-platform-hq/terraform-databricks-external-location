output "storage_credential_name" {
  value       = try(databricks_storage_credential.this[0].name, null)
  description = "Storage Credential name"
}

output "storage_credential_metastore_id" {
  value       = try(databricks_storage_credential.this[0].metastore_id, null)
  description = "Storage Credential metastore id"
}

output "external_locations" {
  value = { for key in keys(local.external_locations_mapped) : key => {
    credential_name = databricks_external_location.this[key].credential_name
    location_name   = databricks_external_location.this[key].name
    url             = databricks_external_location.this[key].url
  } }
  description = "Map of objects with External Location parameters, like name, credentials name and url of target storage"
}

output "databricks_gcp_service_account" {
  value       = try(databricks_storage_credential.this[0].databricks_gcp_service_account[0].email, null)
  description = "The email of the GCP service account created, to be granted access to relevant buckets"
}
