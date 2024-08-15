git clone https://github.com/HappyPathway/terraform-importer-gh-actions.git ../terraform-import-gh-actions-internal || { cd ../terraform-import-gh-actions-internal && git pull origin main; }
cd ../terraform-import-gh-actions-internal
git fetch
git remote add internal git@github.com:HappyPathway/terraform-import-gh-actions-internal.git
git push internal main --force
git push --tags internal
cd ..