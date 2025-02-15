locals {
  # Maps 'external_locations' object, conditionally validates if 'name' parameter is provided
  external_locations_mapped = {
    for object in var.external_locations : object.index => object
    if length(object.index) != 0
  }

  # Filters 'external_locations' mapped local variable for existing valid permissions
  external_locations_permissions_mapped = {
    for k, v in local.external_locations_mapped : k => v.permissions
    if length(v.permissions) != 0
  }
}

resource "databricks_storage_credential" "this" {
  count = var.storage_credential.create_storage_credential ? 1 : 0

  name  = var.storage_credential.name
  owner = var.storage_credential.owner

  # Dynamic block for Azure
  dynamic "azure_managed_identity" {
    for_each = var.cloud == "azure" ? [1] : []
    content {
      access_connector_id = var.storage_credential.azure_access_connector_id
    }
  }

  # Dynamic block for GCP
  dynamic "databricks_gcp_service_account" {
    for_each = var.cloud == "gcp" ? [1] : []
    content {}
  }

  force_destroy  = var.storage_credential.force_destroy
  comment        = var.storage_credential.comment
  isolation_mode = var.cloud == "azure" ? var.storage_credential.isolation_mode : null
}

resource "databricks_grants" "credential" {
  count = var.storage_credential.create_storage_credential ? (length(var.storage_credential.permissions) != 0 ? 1 : 0) : 0

  storage_credential = try(databricks_storage_credential.this[0].id, null)
  dynamic "grant" {
    for_each = var.storage_credential.permissions
    content {
      principal  = grant.value.principal
      privileges = grant.value.privileges
    }
  }
}

resource "databricks_external_location" "this" {
  for_each = local.external_locations_mapped

  name            = each.value.name
  owner           = each.value.owner
  url             = each.value.url
  credential_name = coalesce(try(databricks_storage_credential.this[0].id, null), each.value.credentials_name)
  comment         = each.value.comment
  skip_validation = each.value.skip_validation
  read_only       = each.value.read_only
  force_destroy   = each.value.force_destroy
  force_update    = each.value.force_update
  isolation_mode  = each.value.isolation_mode
}

resource "databricks_grants" "locations" {
  for_each = local.external_locations_permissions_mapped

  external_location = databricks_external_location.this[each.key].id
  dynamic "grant" {
    for_each = each.value
    content {
      principal  = grant.value.principal
      privileges = grant.value.privileges
    }
  }

  depends_on = [databricks_grants.credential]
}
