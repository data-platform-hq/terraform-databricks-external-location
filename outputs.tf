output "storage_credential_name" {
  value       = databricks_storage_credential.this.name
  description = "Storage Credential name"
}

output "storage_credential_metastore_id" {
  value       = databricks_storage_credential.this.metastore_id
  description = "Storage Credential metastore id"
}

output "external_locations" {
  value = {for key in keys(local.external_locations_mapped) : key => {
    credential_name = databricks_external_location.this[key].credential_name
    location_name   = databricks_external_location.this[key].name
    url             = databricks_external_location.this[key].url
  }}
  description = "Map of objects with External Location parameters, like name, credentials name and url of target storage"
}
