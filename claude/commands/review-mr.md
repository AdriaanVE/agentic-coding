# review-mr.md

## Command: review-mr

1. Ask user for branch name
2. Check `git status` for uncommitted changes
   - If dirty: prompt user to commit or stash
   - If commit chosen: run `/git-add-commit`
   - If stash chosen: `git stash push -u -m "Pre-MR-review stash"`
3. Store current branch name
4. `git fetch origin`
5. Detect default base branch: `git symbolic-ref refs/remotes/origin/HEAD | sed 's@^refs/remotes/origin/@@'`, fall back to `main`
6. Check out the MR branch:
   - If it exists locally: `git checkout <mr-branch>`
   - Otherwise: `git checkout -b temp-review origin/<mr-branch>`
7. Generate diff and file list:
   - `git diff origin/<base>...<mr-branch>` (triple-dot, merge-base)
   - `git diff --name-only origin/<base>...<mr-branch>`
   - `git log --oneline origin/<base>..HEAD`
8. **Invoke code-reviewer subagent** with the diff, file list, commit log, and branch context
9. Present report to user
10. **Cleanup (optional — ask the user):**
    <!-- Cleanup is optional because the user often wants to stay on the MR branch to inspect the code themselves -->
    - `git checkout <original-branch>`
    - If `temp-review` was created: `git branch -d temp-review`
    - If stash was used: `git stash pop`
