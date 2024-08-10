provider "github" {
  token = var.public_repo.token # or `GITHUB_TOKEN`
}

data "github_repository" "public_repo" {
  full_name = "${var.public_repo.owner}/${var.public_repo.name}"
}

data "github_ref" "ref" {
  owner      = var.public_repo.owner
  repository = var.public_repo.name
  ref        = "heads/${data.github_repository.public_repo.default_branch}"
}

module "internal_github_actions" {
  source                  = "HappyPathway/repo/github"
  github_repo_description = data.github_repository.public_repo.description
  repo_org                = var.repo_org
  name                    = data.github_repository.public_repo.name
  github_repo_topics = concat([
    "github-actions"
  ], data.github_repository.public_repo.topics)
  force_name        = true
  github_is_private = false
  create_codeowners = false
  enforce_prs       = false
  collaborators     = var.collaborators
  admin_teams       = var.admin_teams
}

resource "null_resource" "git_import" {

  triggers = {
    sha = data.github_ref.ref.sha
  }

  provisioner "local-exec" {
    command = "rm -rf ${path.module}/${var.repo_name} || echo 'No such directory'"
  }

  provisioner "local-exec" {
    command = "git clone ${data.github_repository.public_repo.http_clone_url} ${path.module}/${var.repo_name}"
  }

  provisioner "local-exec" {
    command     = "git fetch"
    working_dir = "${path.module}/${var.repo_name}"
  }

  provisioner "local-exec" {
    command     = "git remote add internal ${module.internal_github_actions.github_repo.ssh_clone_url}"
    working_dir = "${path.module}/${var.repo_name}"
  }

  provisioner "local-exec" {
    command     = "git push internal main --force"
    working_dir = "${path.module}/${var.repo_name}"
  }

  provisioner "local-exec" {
    command     = "git push --tags internal"
    working_dir = "${path.module}/${var.repo_name}"
  }

  provisioner "local-exec" {
    command = "rm -rf ${path.module}/${var.repo_name}"
  }
}