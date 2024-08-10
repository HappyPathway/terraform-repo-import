variable "git_repo_path" {
  description = "The local path where the Git repository will be cloned"
  type        = string
}

variable "repo_org" {
  description = "The GitHub organization for the repository"
  type        = string
}

variable "repo_name" {
  description = "The name of the GitHub repository"
  type        = string
}

variable "repo_topics" {
  description = "Additional topics to add to the GitHub repository"
  type        = list(string)
  default     = []
}

variable "collaborators" {
  description = "List of collaborators to add to the GitHub repository"
  type        = map(string)
  default     = {}
}

variable "admin_teams" {
  description = "List of admin teams for the GitHub repository"
  type        = list(string)
  default     = []
}

variable "public_repo" {
  description = "The public GitHub repository to import"
  type = object({
    owner = string
    name  = string
    token = string
  })
}