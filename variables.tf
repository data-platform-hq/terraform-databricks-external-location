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

variable "suffix" {
  type        = string
  description = "Optional suffix for resource group"
  default     = ""
}

variable "custom_storage_credential_name" {
  type        = string
  description = "Name of storage credential. If not provided will be created in format sc-{var.project}-{var.env}-{var.location}{local.suffix}"
}

variable "managed_identity_id" {
  type        = string
  description = "Managed credential ID to be attached to storage credential"
}

variable "storage_credential_owner" {
  type        = string
  description = "Storage credential owner username"
}

variable "storage_credential_grant_privileges" {
  type        = set(string)
  description = "Privileges granted to storage credentials"
  default     = ["CREATE_EXTERNAL_LOCATION", "CREATE_EXTERNAL_TABLE", "READ_FILES", "WRITE_FILES"]
}

variable "external_locations" {
  type = map(object({
    owner      = optional(string)
    url        = optional(string)
    privileges = optional(set(string))
  }))
  description = "Map of external location names to its owner, ur, privileges"
  default     = {}
}
