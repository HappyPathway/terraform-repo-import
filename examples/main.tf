terraform {
  required_providers {
    github = {
      source  = "integrations/github"
      version = "6.2.2"
    }
  }
}

module "gh_token" {
  source  = "HappyPathway/var/env"
  env_var = "GITHUB_TOKEN"
}

provider "github" {
  alias = "public_repo"
  token = module.gh_token.value
  owner = "HappyPathway"
}

provider "github" {
  alias = "internal_repo"
  token = module.gh_token.value
  owner = "HappyPathway"
}

module "repo_mirror" {
  source = "../"
  public_repo = {
    owner = "HappyPathway"
    name  = "terraform-importer-gh-actions"
  }
  internal_repo = {
    name   = "terraform-import-gh-actions-internal"
    org    = "HappyPathway"
    topics = ["github-actions"]
  }
  providers = {
    github.public_repo   = github.public_repo
    github.internal_repo = github.internal_repo
  }
}

output "public_repo" {
  value = module.repo_mirror.public_repo
}

output "internal_repo" {
  value = module.repo_mirror.internal_repo
}