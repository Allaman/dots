#!/bin/bash
# Git repo audit - 5 quick diagnostics before reading code
# From https://piechowski.io/post/git-commands-before-reading-code/

echo "=== What Changes the Most (top 20 files, last year) ==="
git log --format=format: --name-only --since="1 year ago" | sort | uniq -c | sort -nr | head -20

echo ""
echo "=== Who Built This (contributors by commit count) ==="
git shortlog -sn --no-merges

echo ""
echo "=== Where Do Bugs Cluster (top 20 files in fix/bug commits) ==="
git log -i -E --grep="fix|bug|broken" --name-only --format='' | sort | uniq -c | sort -nr | head -20

echo ""
echo "=== Is This Project Accelerating or Dying (commits by month) ==="
git log --format='%ad' --date=format:'%Y-%m' | sort | uniq -c

echo ""
echo "=== How Often Is the Team Firefighting (reverts/hotfixes, last year) ==="
git log --oneline --since="1 year ago" | grep -iE 'revert|hotfix|emergency|rollback'
