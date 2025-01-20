variable "storage_credential" {
  type = object({
    azure_access_connector_id = optional(string, null) # Azure Databricks Access Connector Id
    name                      = optional(string, null) # Custom whole name of resource
    owner                     = optional(string)       # Owner of resource
    force_destroy             = optional(bool, true)
    comment                   = optional(string, "Managed identity credential provisioned by Terraform")
    permissions = optional(set(object({
      principal  = string
      privileges = list(string)
    })), [])
    isolation_mode = optional(string, "ISOLATION_MODE_OPEN")
  })
  description = "Object with storage credentials configuration attributes"
  default     = {}
}

variable "cloud" {
  type        = string
  description = "Cloud (azure, aws or gcp)"
}

variable "create_storage_credential" {
  type        = bool
  default     = true
  description = "Boolean flag that determines whether to create storage credential or use the existing one"
}

variable "external_locations" {
  type = list(object({
    index            = string                # Index of instance, for example short name, used later to access exact external location in output map
    name             = string                # Custom whole name of resource
    url              = string                # Path URL in cloud storage
    credentials_name = optional(string)      # If create_storage_credential is set to false, provide id of existing storage credential here
    owner            = optional(string)      # Owner of resource
    skip_validation  = optional(bool, true)  # Suppress validation errors if any & force save the external location
    read_only        = optional(bool, false) # Indicates whether the external location is read-only.
    force_destroy    = optional(bool, true)
    force_update     = optional(bool, true)
    comment          = optional(string, "External location provisioned by Terraform")
    permissions = optional(set(object({
      principal  = string
      privileges = list(string)
    })), [])
    isolation_mode = optional(string, "ISOLATION_MODE_OPEN")
  }))
  description = "List of object with external location configuration attributes"
  default     = []
}
