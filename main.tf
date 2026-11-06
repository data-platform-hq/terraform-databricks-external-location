locals {
  external_locations_mapped = {
    for object in var.external_locations : object.index => object
    if length(object.index) != 0
  }
  external_locations_permissions_mapped = {
    for k, v in local.external_locations_mapped : k => v.permissions
    if length(v.permissions) != 0
  }
  create_aws_credential = (
    var.storage_credential.create_storage_credential &&
    var.storage_credential.cloud == "aws" &&
    var.aws_credentials.account_id != null &&
    var.aws_credentials.iam_role_name != null
  )
}

resource "databricks_storage_credential" "this" {
  count = var.storage_credential.cloud != "" && var.storage_credential.create_storage_credential ? 1 : 0

  name  = var.storage_credential.name
  owner = var.storage_credential.owner

  # Dynamic block for Azure
  dynamic "azure_managed_identity" {
    for_each = var.storage_credential.cloud == "azure" ? [1] : []
    content {
      access_connector_id = var.storage_credential.azure_access_connector_id
    }
  }

  # Dynamic block for GCP
  dynamic "databricks_gcp_service_account" {
    for_each = var.storage_credential.cloud == "gcp" ? [1] : []
    content {}
  }

  # Dynamic block for AWS
  dynamic "aws_iam_role" {
    for_each = local.create_aws_credential ? [1] : []
    content {
      role_arn = "arn:aws:iam::${var.aws_credentials.account_id}:role/${var.aws_credentials.iam_role_name}"
    }
  }

  force_destroy  = var.storage_credential.force_destroy
  comment        = var.storage_credential.comment
  isolation_mode = var.storage_credential.cloud == "azure" ? var.storage_credential.isolation_mode : null
}

# ── AWS IAM lifecycle ──────────────────────────────────────────────────────────

data "databricks_aws_unity_catalog_assume_role_policy" "this" {
  count          = local.create_aws_credential ? 1 : 0
  aws_account_id = var.aws_credentials.account_id
  role_name      = var.aws_credentials.iam_role_name
  external_id    = databricks_storage_credential.this[0].aws_iam_role[0].external_id
}

data "databricks_aws_unity_catalog_policy" "this" {
  for_each       = local.create_aws_credential ? var.aws_credentials.bucket_names : {}
  aws_account_id = var.aws_credentials.account_id
  bucket_name    = each.value
  role_name      = var.aws_credentials.iam_role_name
}

resource "aws_iam_policy" "this" {
  for_each = local.create_aws_credential ? var.aws_credentials.bucket_names : {}
  name     = each.value
  policy   = data.databricks_aws_unity_catalog_policy.this[each.key].json
}

resource "aws_iam_role" "this" {
  count                = local.create_aws_credential ? 1 : 0
  name                 = var.aws_credentials.iam_role_name
  assume_role_policy   = data.databricks_aws_unity_catalog_assume_role_policy.this[0].json
  permissions_boundary = var.aws_credentials.iam_role_boundary_arn
}

resource "aws_iam_role_policy_attachment" "this" {
  for_each   = local.create_aws_credential ? var.aws_credentials.bucket_names : {}
  role       = aws_iam_role.this[0].name
  policy_arn = aws_iam_policy.this[each.key].arn
}

resource "databricks_grants" "credential" {
  count = var.storage_credential.cloud != "" && length(var.storage_credential.permissions) > 0 ? 1 : 0

  storage_credential = try(databricks_storage_credential.this[0].id, var.storage_credential.name)
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
