resource "null_resource" "git_clone" {
  provisioner "local-exec" {
    command = "rm ${var.git_repo_path} || echo 'No such file'"
  }

  provisioner "local-exec" {
    command = "git clone ${var.git_repo_url} ${var.git_repo_path}"
  }

  provisioner "local-exec" {
    command     = "git fetch"
    working_dir = var.git_repo_path
  }
}


module "internal_github_actions" {
  source                  = "HappyPathway/repo/github"
  github_repo_description = "Imported External Github Actions Repository"
  repo_org                = var.repo_org
  name                    = var.repo_name
  github_repo_topics = concat([
    "github-actions"
  ], var.repo_topics)
  force_name        = true
  github_is_private = false
  create_codeowners = false
  enforce_prs       = false
  collaborators     = var.collaborators
  admin_teams       = var.admin_teams
}

resource "null_resource" "git_clone_new_repo" {
  # provisioner "local-exec" {
  #   command     = "git remote rm origin"
  #   working_dir = var.git_repo_path
  # }

  provisioner "local-exec" {
    command     = "git remote add internal ${module.internal_github_actions.github_repo.ssh_clone_url}"
    working_dir = var.git_repo_path
  }


  # provisioner "local-exec" {
  #   command     = "rm .gitignore README.md || echo 'No such file'"
  #   working_dir = var.git_repo_path
  # }

  # provisioner "local-exec" {
  #   command     = "git pull origin main --allow-unrelated-histories"
  #   working_dir = var.git_repo_path
  # }

  provisioner "local-exec" {
    command     = "git push internal main --force"
    working_dir = var.git_repo_path
  }

  provisioner "local-exec" {
    command     = "git push --tags internal"
    working_dir = var.git_repo_path
  }

  depends_on = [
    module.internal_github_actions,
    null_resource.git_clone
  ]
}