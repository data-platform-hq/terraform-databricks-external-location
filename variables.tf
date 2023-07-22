variable "project" {
  type        = string
  description = "Project name"
}

variable "env" {
  type        = string
  description = "Environment name"
}

variable "location" {
  type        = string
  description = "Azure location"
}

variable "storage_credential" {
  type = object({
    azure_access_connector_id = string               # Azure Databricks Access Connector Id
    name                      = optional(string, "") # Custom whole name of resource
    prefix                    = optional(string, "") # Unique prefix of resource. It would be created with default prefix and default name
    owner                     = optional(string)     # Owner of resource
    comment                   = optional(string, "Managed identity credential provisioned by Terraform")
    permissions = optional(set(object({
      principal  = string
      privileges = list(string)
    })), [])
  })

  validation {
    condition     = anytrue([length(var.storage_credential.name) != 0, length(var.storage_credential.prefix) != 0, ])
    error_message = "Either name or prefix parameters should be provided"
  }
}

variable "external_locations" {
  type = set(object({
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
  default = []
}
