# Databricks Workspace Terraform module
Terraform module used for Databricks Storage credentials and external location creation.

## Usage
This module provides an ability to create Storage credentials and external location within Databricks Workspace

```hcl
locals {
  external_locations = {
    "dev-storage" = {
      owner      = "username@domain.com"
      url        = "abfss://container@storageaccount.dfs.core.windows.net"
      privileges = ["CREATE_EXTERNAL_TABLE", "READ_FILES", "CREATE_MANAGED_STORAGE", "WRITE_FILES"]
    }
  }
}

# Prerequisite resources
data "azurerm_databricks_workspace" "example" {
  name                = "example-workspace"
  resource_group_name = "example-rg"
}

# Databricks Provider configuration
provider "databricks" {
  alias                       = "main"
  host                        = data.azurerm_databricks_workspace.example.workspace_url
  azure_workspace_resource_id = data.azurerm_databricks_workspace.example.id
}

# Databricks External Locations module usage example
module "databricks_runtime_core" {
  source = "data-platform-hq/databricks-runtime/databricks"
}

module "databricks_locations" {
  source                              = "data-platform-hq/databricks-ws/locations"
  env                                 = var.env
  project                             = var.project
  location                            = var.location
  custom_storage_credential_name      = "custom_credentials"
  storage_credential_grant_privileges = ["CREATE_EXTERNAL_LOCATION", "CREATE_EXTERNAL_TABLE", "READ_FILES", "WRITE_FILES"]
  external_locations = local.external_locations
  managed_identity_id      = var.managed_identity_id
  storage_credential_owner = "username@domain.com"

  providers = {
    databricks = databricks.main
  }
}
```
<!-- BEGIN_TF_DOCS -->
## Requirements

| Name                                                                         | Version   |
| ---------------------------------------------------------------------------- | --------- |
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform)    | >= 1.0.0  |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm)          | >= 3.40.0 |
| <a name="requirement_databricks"></a> [databricks](#requirement\_databricks) | >= 1.9.2  |

## Providers

| Name                                                                   | Version |
| ---------------------------------------------------------------------- | ------- |
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm)          | 3.40.0  |
| <a name="provider_databricks"></a> [databricks](#provider\_databricks) | 1.9.2   |

## Modules

No modules.

## Resources

| Name                                                                                                                                         | Type     |
|----------------------------------------------------------------------------------------------------------------------------------------------| -------- |
| [databricks_storage_credential.this](https://registry.terraform.io/providers/databricks/databricks/latest/docs/resources/storage_credential) | resource |
| [databricks_grants.credential](https://registry.terraform.io/providers/databricks/databricks/latest/docs/resources/grants)                   | resource |
| [databricks_external_location.this](https://registry.terraform.io/providers/databricks/databricks/latest/docs/resources/external_location)   | resource |
| [databricks_grants.locations](https://registry.terraform.io/providers/databricks/databricks/latest/docs/resources/grants)                    | resource |

## Inputs

| Name                                                                                                                                              | Description                                                                                                                   | Type                                                                                                                                    | Default                                                                             | Required |
|---------------------------------------------------------------------------------------------------------------------------------------------------|-------------------------------------------------------------------------------------------------------------------------------|-----------------------------------------------------------------------------------------------------------------------------------------|-------------------------------------------------------------------------------------|:--------:|
| <a name="input_project"></a> [project](#input\_project)                                                                                           | Project name                                                                                                                  | `string`                                                                                                                                | n/a                                                                                 |   yes    |
| <a name="input_env"></a> [env](#input\_env)                                                                                                       | Environment name                                                                                                              | `string`                                                                                                                                | n/a                                                                                 |   yes    |
| <a name="input_location"></a> [location](#input\_location)                                                                                        | Azure location                                                                                                                | `string`                                                                                                                                | n/a                                                                                 |   yes    |
| <a name="input_suffix"></a> [suffix](#input\_suffix)                                                                                              | Name suffix                                                                                                                   | `string`                                                                                                                                | `""`                                                                                |    no    |
| <a name="input_custom_storage_credential_name"></a> [custom\_storage\_credential\_name](#input\_custom\_storage\_credential\_name)                | Name of storage credential. If not provided will be created in format sc-{var.project}-{var.env}-{var.location}{local.suffix} | `string`                                                                                                                                | n/a                                                                                 |    no    |
| <a name="input_managed_identity_id"></a> [managed\_identity\_id](#input\_managed\_identity\_id)                                                   | Managed credential ID to be attached to storage credential                                                                    | `string`                                                                                                                                | `""`                                                                                |   yes    |
| <a name="input_storage_credential_owner"></a> [storage\_credential\_owner](#input\_storage\_credential\_owner)                                    | Storage credential owner username                                                                                             | `string`                                                                                                                                | `""`                                                                                |   yes    |
| <a name="input_storage_credential_grant_privileges"></a> [storage\_credential\_grant\_privileges](#input\_storage\_credential\_grant\_privileges) | Privileges granted to storage credentials                                                                                     | `set(string)`                                                                                                                           | ["CREATE_EXTERNAL_LOCATION", "CREATE_EXTERNAL_TABLE", "READ_FILES", "WRITE_FILES"]  |    no    |
| <a name="input_external_locations"></a> [external\_locations](#input\_external\_locations)                                                        | Map of external location names to its owner, ur, privileges                                                                   | <pre>map(object({<br> owner = optional(string) <br> url  = optional(string) <br> privileges    = optional(set(string)) <br>}))</pre>    | {}                                                                                  |    no    |



## Outputs

<!-- END_TF_DOCS -->

## License

Apache 2 Licensed. For more information please see [LICENSE](https://github.com/data-platform-hq/terraform-databricks-databricks-runtime/blob/main/LICENSE)
