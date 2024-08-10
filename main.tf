data "github_repository" "public_repo" {
  provider  = github.public_repo
  full_name = "${var.public_repo.owner}/${var.public_repo.name}"
}

data "github_ref" "ref" {
  provider   = github.public_repo
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
  providers = {
    github = github.internal_repo
  }
}

resource "local_file" "script" {
  filename = "${path.module}/import.sh"
  content = templatefile("${path.module}/script.tpl", {
    repo_path               = local.repo_path
    public_clone_url        = data.github_repository.public_repo.http_clone_url
    internal_clone_url      = module.internal_github_actions.github_repo.ssh_clone_url
    internal_default_branch = module.internal_github_actions.github_repo.default_branch
    cur_dir                 = path.module
  })
}

resource "null_resource" "git_import" {

  triggers = {
    sha = data.github_ref.ref.sha
  }

  provisioner "local-exec" {
    command = local_file.script.filename
  }

  depends_on = [local_file.script]
}