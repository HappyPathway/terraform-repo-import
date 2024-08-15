variable "internal_repo" {
  description = "The internal GitHub repository to create"
  type = object({
    name          = string
    org           = string
    topics        = optional(list(string), [])
    collaborators = optional(map(string), {})
    admin_teams   = optional(list(string), [])
  })
}

variable "public_repo" {
  description = "The public GitHub repository to import"
  type = object({
    owner = string
    name  = string
  })
}

variable "github_org_teams" {
  description = "The GitHub organization teams to add to the repository"
  type        = list(any)
  default     = []
}