#!/usr/bin/env bash
# 正文在本文件夹。GitHub Pages 从 gh-pages 分支的根目录打开原来的地址。
set -euo pipefail

PROTO="$(cd "$(dirname "$0")" && pwd)"
ROOT="$(cd "$PROTO/.." && pwd)"
cd "$ROOT"

msg="${1:-chore: update preview}"

owner_repo="$(gh repo view --json nameWithOwner -q .nameWithOwner 2>/dev/null || true)"
if [ -z "$owner_repo" ]; then
  origin="$(git remote get-url origin)"
  owner_repo="$(echo "$origin" | sed -E 's#.*github.com[:/](.+)(\.git)?#\1#' | sed 's/\.git$//')"
fi

site="$(mktemp -d)"
idx="$(mktemp)"
cleanup() {
  rm -rf "$site"
  rm -f "$idx"
}
trap cleanup EXIT

cp "$PROTO/index.html" "$PROTO/pc.html" "$PROTO/h5.html" "$PROTO/robots.txt" "$site/"
: > "$site/.nojekyll"

# 先把三个页面铺到 gh-pages 根目录，已发布地址不变。
GIT_INDEX_FILE="$idx" GIT_WORK_TREE="$site" git add -A
tree="$(GIT_INDEX_FILE="$idx" git write-tree)"
git fetch origin gh-pages >/dev/null 2>&1 || true
if git rev-parse --verify --quiet refs/remotes/origin/gh-pages >/dev/null; then
  old="$(git rev-parse refs/remotes/origin/gh-pages)"
  old_tree="$(git rev-parse "${old}^{tree}")"
else
  old=""
  old_tree=""
fi
if [ "$tree" != "$old_tree" ]; then
  if [ -n "$old" ]; then
    commit="$(git commit-tree "$tree" -p "$old" -m "$msg")"
  else
    commit="$(git commit-tree "$tree" -m "$msg")"
  fi
  git update-ref refs/heads/gh-pages "$commit"
  git push -u origin gh-pages
fi

gh api --method PUT "repos/${owner_repo}/pages" --input - <<EOF
{"build_type":"legacy","source":{"branch":"gh-pages","path":"/"}}
EOF
src="$(gh api "repos/${owner_repo}/pages" --jq .source.branch)"
if [ "$src" != "gh-pages" ]; then
  echo "GitHub Pages 仍指向 ${src}，已停止推送 main，避免原来的地址打不开。" >&2
  exit 1
fi

git add \
  "原型/pc.html" "原型/h5.html" "原型/index.html" \
  "原型/publish.sh" "原型/README.md" "原型/robots.txt" \
  "原型/docs" \
  .gitignore .nojekyll
if [ -f "原型/数据权限表.docx" ]; then
  git add "原型/数据权限表.docx"
fi
if [ -d "需求文档" ]; then
  git add "需求文档"
fi
git add -u -- index.html pc.html h5.html README.md publish.sh robots.txt docs

if git diff --cached --quiet; then
  echo "No changes to commit."
else
  git commit -m "$msg"
fi

branch="$(git rev-parse --abbrev-ref HEAD)"
git push -u origin "$branch"

pages="https://$(echo "$owner_repo" | cut -d/ -f1).github.io/$(echo "$owner_repo" | cut -d/ -f2)"
echo ""
echo "Published:"
echo "  $pages/"
echo "  $pages/pc.html"
echo "  $pages/h5.html"
