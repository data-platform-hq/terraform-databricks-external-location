variable "storage_credential" {
  type = object({
    azure_access_connector_id = string           # Azure Databricks Access Connector Id
    name                      = string           # Custom whole name of resource
    owner                     = optional(string) # Owner of resource
    comment                   = optional(string, "Managed identity credential provisioned by Terraform")
    permissions = optional(set(object({
      principal  = string
      privileges = list(string)
    })), [])
  })
}

variable "external_locations" {
  type = list(object({
    name            = string                # Custom whole name of resource
    url             = string                # Path URL in cloud storage
    owner           = optional(string)      # Owner of resource
    skip_validation = optional(bool, true)  # Suppress validation errors if any & force save the external location
    read_only       = optional(bool, false) # Indicates whether the external location is read-only.
    comment         = optional(string, "External location provisioned by Terraform")
    permissions = optional(set(object({
      principal  = string
      privileges = list(string)
    })), [])
  }))
  #  description = "Map of external location names to its owner, ur, privileges"
  default = []
}