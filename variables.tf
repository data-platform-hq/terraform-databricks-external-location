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

variable "storage_credential" {
  type = object({
    custom_name         = optional(string)
    owner               = string
    managed_identity_id = string
    privileges          = set(string)
  })
  description = "Map of external location names to its owner, ur, privileges"
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
