terraform {
  required_providers {
    github = {
      source  = "integrations/github"
      version = ">= 6.2.2"
      configuration_aliases = [
        github.public_repo,
        github.internal_repo
      ]
    }
  }
}
