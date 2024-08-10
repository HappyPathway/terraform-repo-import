terraform {
  required_providers {
    github = {
      source  = "integrations/github"
      version = ">= 6.2.3"
      configuration_aliases = [
        github.public_repo,
        github.internal_repo
      ]
    }
  }
}
