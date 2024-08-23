data "github_repository" "public_repo" {
  provider  = github.public_repo
  full_name = "${var.public_repo.owner}/${var.public_repo.name}"
}

data "github_ref" "ref" {
  provider   = github.public_repo
  owner      = var.public_repo.owner
  repository = var.public_repo.name
  ref        = "heads/${data.github_repository.public_repo.default_branch != null ? data.github_repository.public_repo.default_branch : "main"}"
}

module "internal_github_actions" {
  source                  = "HappyPathway/repo/github"
  github_repo_description = data.github_repository.public_repo.description
  repo_org                = var.internal_repo.org
  name                    = var.internal_repo.name
  github_repo_topics = concat([
    "github-actions"
    ],
    data.github_repository.public_repo.topics != null ?
    length(data.github_repository.public_repo.topics) > 0 ? data.github_repository.public_repo.topics : []
    : []
  )
  force_name        = true
  github_is_private = false
  create_codeowners = false
  enforce_prs       = false
  collaborators     = var.internal_repo.collaborators
  # yes, this is a bug, but it's a bug in the module, not the code
  admin_teams      = var.internal_repo.admin_teams
  github_org_teams = var.github_org_teams
  providers = {
    github = github.internal_repo
  }
  vulnerability_alerts = var.vulnerability_alerts
}

resource "local_file" "script" {
  filename = "${path.module}/import.sh"
  content = templatefile("${path.module}/script.tpl", {
    repo_path               = local.repo_path
    public_clone_url        = data.github_repository.public_repo.http_clone_url
    internal_clone_url      = module.internal_github_actions.github_repo.ssh_clone_url
    internal_default_branch = module.internal_github_actions.github_repo.default_branch
    public_default_branch   = data.github_repository.public_repo.default_branch
    cur_dir                 = path.module
  })
  depends_on = [data.github_repository.public_repo]
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

output "public_repo" {
  value = data.github_repository.public_repo
}

output "internal_repo" {
  value = module.internal_github_actions.github_repo
}
