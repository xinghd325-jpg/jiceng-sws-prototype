#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"

msg="${1:-chore: update prototype}"

git add pc.html h5.html index.html publish.sh .gitignore README.md
if [ -d "需求文档" ]; then
  git add "需求文档"
fi

if git diff --cached --quiet; then
  echo "没有需要提交的变更。"
else
  git commit -m "$msg"
fi

branch="$(git rev-parse --abbrev-ref HEAD)"
git push -u origin "$branch"

owner_repo="$(gh repo view --json nameWithOwner -q .nameWithOwner 2>/dev/null || true)"
if [ -z "$owner_repo" ]; then
  origin="$(git remote get-url origin)"
  owner_repo="$(echo "$origin" | sed -E 's#.*github.com[:/](.+)(\.git)?#\1#' | sed 's/\.git$//')"
fi
pages="https://$(echo "$owner_repo" | cut -d/ -f1).github.io/$(echo "$owner_repo" | cut -d/ -f2)"
echo ""
echo "已发布："
echo "  入口  $pages/"
echo "  PC    $pages/pc.html"
echo "  H5    $pages/h5.html"
