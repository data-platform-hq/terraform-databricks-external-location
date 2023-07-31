output "storage_credential_name" {
  value       = databricks_storage_credential.this.name
  description = "Storage Credential name"
}

output "storage_credential_metastore_id" {
  value       = databricks_storage_credential.this.metastore_id
  description = "Storage Credential Metastore id"
}

output "external_locations" {
  value = [for key in keys(local.external_locations_mapped) : {
    credential_name = databricks_external_location.this[key].credential_name
    location_name   = databricks_external_location.this[key].name
    url             = databricks_external_location.this[key].url
  }]
  description = "Object with External Location parameters, like name, credentials name and url of target storage"
}
