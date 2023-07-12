locals {
  suffix                  = length(var.suffix) == 0 ? "" : "-${var.suffix}"
  storage_credential_name = var.custom_storage_credential_name == null ? "sc-${var.project}-${var.env}-${var.location}${local.suffix}" : "${var.custom_storage_credential_name}${local.suffix}"
}

resource "databricks_storage_credential" "this" {
  name  = local.storage_credential_name
  owner = var.storage_credential_owner
  azure_managed_identity {
    access_connector_id = var.managed_identity_id
  }
  comment = "Managed identity credential managed by TF"
}

resource "databricks_grants" "credential" {
  storage_credential = databricks_storage_credential.this.id
  grant {
    principal  = var.storage_credential_owner
    privileges = var.storage_credential_grant_privileges
  }
}

resource "databricks_external_location" "this" {
  for_each = var.external_locations

  name            = each.key
  owner           = each.value.owner
  url             = each.value.url
  credential_name = databricks_storage_credential.this.id
  comment         = "Managed by TF"
}

resource "databricks_grants" "locations" {
  for_each = var.external_locations

  external_location = databricks_external_location.this[each.key].id
  grant {
    principal  = "account users"
    privileges = each.value.privileges
  }
}
