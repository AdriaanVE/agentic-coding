# git-add-commit.md

## Command: git-add-commit

1. Check `git status` for uncommitted changes
   - If clean (no staged, unstaged, or untracked changes): inform user and stop
   - If branch = main: give very clear warning that this is not good practice and ask permission to continue
2. Show the list of changed/untracked files and ask the user to confirm which files to stage
3. If `.pre-commit-config.yaml` exists: run `uv run pre-commit run --all-files`
   - If pre-commit modified files, re-stage the affected files
4. Generate a good commit message based on the diff
   - Ask for confirmation of the message before committing
   - Never put Claude as the author of the commit
5. Commit changes: `git commit -m "<commit-message>"`
6. Ask if user wants to push changes to remote
   - If yes, check if the current branch tracks a remote
   - If no upstream is set: inform the user and ask permission before running `git push --set-upstream origin <branch-name>`
   - Otherwise: `git push`
