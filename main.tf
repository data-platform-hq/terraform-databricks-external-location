locals {
  credential_name = length(var.storage_credential.name) != 0 ? var.storage_credential.name : "${var.storage_credential.prefix}-${var.project}-${var.env}-${var.location}"

  # Maps 'external_locations' object, conditionally validates if 'name' parameter is provided
  external_locations_mapped = {
    for object in var.external_locations : object.name => object if length(object.name) != 0
  }

  # Filters 'external_locations' mapped local variable for existing valid permissions
  external_locations_permissions_mapped = {
    for k, v in local.external_locations_mapped : k => v.permissions if length(v.permissions) != 0
  }
}

resource "databricks_storage_credential" "this" {
  name  = local.credential_name
  owner = var.storage_credential.owner

  azure_managed_identity {
    access_connector_id = var.storage_credential.azure_access_connector_id
  }

  comment = var.storage_credential.comment
}

resource "databricks_grants" "credential" {
  count = length(var.storage_credential.permissions) != 0 ? 1 : 0

  storage_credential = databricks_storage_credential.this.id
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

  name            = each.key
  owner           = each.value.owner
  url             = each.value.url
  credential_name = databricks_storage_credential.this.id
  comment         = each.value.comment
  skip_validation = each.value.skip_validation
  read_only       = each.value.read_only
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
}
