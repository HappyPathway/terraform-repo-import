git clone ${public_clone_url} ${repo_path} || { cd ${repo_path} && git pull origin ${public_default_branch}; }
cd ${repo_path}
git fetch
git remote add internal ${internal_clone_url}
git push internal ${internal_default_branch} --force
git push --tags internal
cd ${cur_dir}