# Azure Databricks External Location Terraform module
Terraform module for creation Azure Databricks External Location

## Usage
```hcl
# Prerequisite resources

# Databricks Workspace with Premium SKU
data "azurerm_databricks_workspace" "example" {
  name                = "example-workspace"
  resource_group_name = "example-rg"
}

resource "azurerm_databricks_access_connector" "example" {
  name                = "example-resource"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location

  identity {
    type = "SystemAssigned"
  }
}

# Databricks Provider configuration
provider "databricks" {
  alias                       = "main"
  host                        = data.azurerm_databricks_workspace.example.workspace_url
  azure_workspace_resource_id = data.azurerm_databricks_workspace.example.id
}

locals {
  storage_credentials = {
    prefix                    = "example"
    azure_access_connector_id = azurerm_databricks_access_connector.example.id
    permissions               = [{ principal = "ALL_PRIVILEGES_GROUP", privileges = ["ALL_PRIVILEGES"] }]
  }
  
  external_locations = 
    {
      name        = "adls-example"
      url         = "abfss://container@storageaccount.dfs.core.windows.net"
      permissions = [
        { principal = "ALL_PRIVILEGES_GROUP", privileges = ["ALL_PRIVILEGES"] },
        { principaprincipal = "EXAMPLE_PERMISSION_GROUP", privileges = ["CREATE_EXTERNAL_TABLE", "READ_FILES"] }
      ]    
      owner           = "username@domain.com"
      skip_validation = true
      read_only       = false
      comment         = "example_comment"
    }    
}

# Databricks External Location 
module "databricks_locations" {
  count  = var.databricks_configure ? (module.databricks_workspace.sku == "premium" ? 1 : 0) : 0

  source  = "data-platform-hq/external-location/databricks"
  version  = "~> 1.0"

  project            = "datahq"
  env                = "example"
  location           = "eastus"
  storage_credential = local.storage_credentials
  external_locations = local.external_locations

  providers = {
    databricks = databricks.workspace
  }
}
```

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name                                                                         | Version   |
| ---------------------------------------------------------------------------- | --------- |
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform)    | >= 1.0.0  |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm)          | >= 3.40.0 |
| <a name="requirement_databricks"></a> [databricks](#requirement\_databricks) | >= 1.19.0 |

## Providers

| Name                                                                   | Version |
| ---------------------------------------------------------------------- | ------- |
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm)          | 3.40.0  |
| <a name="provider_databricks"></a> [databricks](#provider\_databricks) | 1.19.0  |

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

| Name | Description | Type | Default                                                                                                                                               | Required |
|------|-------------|------|-------------------------------------------------------------------------------------------------------------------------------------------------------|:--------:|
| <a name="input_project"></a> [project](#input\_project)| Project name | `string` | n/a | yes |
| <a name="input_env"></a> [env](#input\_env)| Environment name | `string` | n/a | yes |
| <a name="input_location"></a> [resource\_location](#input\_location)| Azure location | `string` | n/a | yes |
| <a name="input_storage_credential"></a> [storage\_credential](#input\_storage\_credential)| Configuration options for Storage Credentials | <pre>object({<br>  azure_access_connector_id = string<br>  name                      = optional(string)<br>  prefix                    = optional(string)<br>  owner                     = optional(string)<br>  comment                   = optional(string)<br>  permissions = optional(set(object({<br>    principal  = string<br>    privileges = list(string)<br>  })))<br>})</pre>  | <pre>object({<br>  azure_access_connector_id = string<br>  name                      = optional(string, "")<br>  prefix                    = optional(string, "")<br>  owner                     = optional(string)<br>  comment                   = optional(string, "Managed identity credential provisioned by Terraform")<br>  permissions = optional(set(object({<br>    principal  = string<br>    privileges = list(string)<br>  })), [])<br>})</pre>  | no |
| <a name="input_external_locations"></a> [external\_locations](#input\_external\_locations)| Configuration options for External Locations | <pre>set(object({<br>  name            = string<br>  url             = string<br>  owner           = optional(string)<br>  skip_validation = optional(bool)<br>  read_only       = optional(bool)<br>  comment         = optional(string)<br>  permissions = optional(set(object({<br>    principal  = string<br>    privileges = list(string)<br>  }))<br>}))</pre> | <pre>set(object({<br>  name            = string<br>  url             = string<br>  owner           = optional(string)<br>  skip_validation = optional(bool, true)<br>  read_only       = optional(bool, false)<br>  comment         = optional(string, "External location provisioned by Terraform")<br>  permissions = optional(set(object({<br>    principal  = string<br>    privileges = list(string)<br>  })), [])<br>}))</pre> | yes |

## Outputs

| Name                                                                                                                          | Description                                          |
| ----------------------------------------------------------------------------------------------------------------------------- | ---------------------------------------------------- |
| <a name="output_storage_credential_name"></a> [storage\_credential\_name](#output\_storage\_credential\_name)                 | Storage Credential name                              |
| <a name="output_storage_credential_metastore_id"></a> [storage\_credential\_metastore\_id](#output\_storage\_credential\_metastore\_id) | Storage Credential Metastore id            |
| <a name="output_external_locations"></a> [external\_locations](#output\_external\_locations)                 | Object with External Location parameters, like name, credentials name and url of target storage |
<!-- END_TF_DOCS -->

## License

Apache 2 Licensed. For more information please see [LICENSE](https://github.com/data-platform-hq/terraform-databricks-external-location/blob/main/LICENSE)
