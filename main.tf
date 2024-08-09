resource "null_resource" "git_clone" {
  provisioner "local-exec" {
    command = "git clone ${var.git_repo_url} ${var.git_repo_path}"
  }
}

module "ghe_runners" {
  source                  = "HappyPathway/repo/github"
  github_repo_description = "Imported External Github Actions Repository"
  repo_org                = var.repo_org
  name                    = var.repo_name
  github_repo_topics = concat([
    "github_actions"
  ], var.repo_topics)
  force_name        = true
  github_is_private = false
  create_codeowners = false
  enforce_prs       = false
  collaborators     = var.collaborators
  admin_teams       = var.admin_teams
}

resource "null_resource" "git_clone_new_repo" {
  provisioner "local-exec" {
    command     = "git remote rm origin"
    working_dir = var.git_repo_path
  }

  provisioner "local-exec" {
    command     = "git remote add origin ${module.ghe_runners.ssh_clone_url}"
    working_dir = var.git_repo_path
  }

  provisioner "local-exec" {
    command     = "git pull origin main --allow-unrelated-histories"
    working_dir = var.git_repo_path
  }

  provisioner "local-exec" {
    command     = "git push origin main --force"
    working_dir = var.git_repo_path
  }

  depends_on = [
    module.ghe_runners,
    null_resource.git_clone
  ]
}