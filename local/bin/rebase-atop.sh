#!/usr/bin/env bash
# ===dotfiles===

set -e
set -x

current_branch="$(git rev-parse --abbrev-ref HEAD)"

other_branch=$1
timestamp="$(date +%s)"

patch_file="/tmp/rebase-atop.${timestamp}.patch"
temp_branch="rebase-atop.${timestamp}"

git diff --patch "origin/dev...${other_branch}" > "${patch_file}"

git checkout -b "${temp_branch}" origin/dev
git apply --3way "${patch_file}"
git commit -m "SQUASHED FROM: ${other_branch}"
temp_commit="$(git rev-parse HEAD)"

git checkout "${current_branch}"
GIT_SEQUENCE_EDITOR="sed -ie '1 i\pick ${temp_commit}'" git rebase -i origin/dev^

git br -D "${temp_branch}"
rm "${patch_file}"
