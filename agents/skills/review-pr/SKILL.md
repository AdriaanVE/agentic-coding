---
name: review-pr
description: Diff-focused PR/MR review with optional Codex second opinion, interactive finding-by-finding discussion and inline comment posting
---

# Claude Code Skill: Review PR/MR

Diff-focused pull request or merge request review. Optionally runs Codex in parallel for a second opinion. Walks through findings one-by-one with the user, discussing severity and posting comments with approval.

---

## When to use

Trigger phrases: "review pr", "review-pr", "/review-pr", "review mr", "review merge request", "review pull request", "pr review", "mr review"

## Arguments

Free-form string. Can be:
- A PR/MR number (e.g. `100`, `#100`)
- A PR/MR URL (e.g. `https://github.com/org/repo/pull/100` or `https://gitlab.com/org/repo/-/merge_requests/42`)
- A branch name to review
- Empty (auto-detect current branch's open PR/MR)

---

## Steps

### 1. Detect platform (GitHub vs GitLab)

Determine the platform from the remote URL:

```bash
git remote get-url origin
```

- If contains `github.com` -> use `gh` CLI
- If contains `gitlab` -> use `glab` CLI
- If ambiguous, ask the user

Store the platform for all subsequent commands. Use the correct CLI throughout:
- GitHub: `gh pr view`, `gh api`
- GitLab: `glab mr view`, `glab api`

### 2. Handle uncommitted changes

Check for uncommitted work:

```bash
git status --porcelain
```

If there are uncommitted changes, **ask the user** what to do:
- **Stash**: `git stash push -u -m "Pre-review stash (review-pr skill)"`
- **Commit**: ask user for commit message, then stage and commit
- **Abort**: stop the review

Remember the choice for cleanup in step 10.

### 3. Identify the PR/MR and base branch

Based on the argument provided:

**If PR/MR number or URL given:**
- GitHub: `gh pr view <number> --json headRefName,baseRefName,title,body,number,url`
- GitLab: `glab mr view <number> --output json`

**If branch name given:**
- Look up the open PR/MR for that branch

**If no argument:**
- Check if current branch has an open PR/MR:
  - GitHub: `gh pr view --json headRefName,baseRefName,title,body,number,url`
  - GitLab: `glab mr view --output json`

Extract and store:
- `HEAD_BRANCH`: the PR/MR source branch
- `BASE_BRANCH`: the PR/MR target branch (do NOT assume `main`)
- `PR_NUMBER` / `MR_NUMBER`
- `PR_URL` / `MR_URL`

### 4. Checkout the branch locally

```bash
git fetch origin <HEAD_BRANCH>
```

Store current branch name for cleanup:
```bash
git branch --show-current
```

Checkout the PR/MR branch:
```bash
git checkout <HEAD_BRANCH>
```

If the branch doesn't exist locally:
```bash
git checkout -b <HEAD_BRANCH> origin/<HEAD_BRANCH>
```

### 5. Generate the diff

Use triple-dot diff (merge-base) to get only what this PR/MR introduces:

```bash
git diff origin/<BASE_BRANCH>...origin/<HEAD_BRANCH>
git diff --stat origin/<BASE_BRANCH>...origin/<HEAD_BRANCH>
git diff --name-only origin/<BASE_BRANCH>...origin/<HEAD_BRANCH>
git log --oneline origin/<BASE_BRANCH>...origin/<HEAD_BRANCH>
```

### 6. Review the diff

**Your review (always runs):**

Review the diff with these principles:

1. **Focus on the diff.** Only flag issues that are introduced or changed by this PR/MR. Do NOT flag pre-existing code that was merely moved or reorganized.
2. **Cross-reference old code.** When a file is deleted and a new file is added with similar logic, compare them. If the logic is unchanged, it is not a finding.
3. **Check for regressions.** Does the refactored code preserve the original behavior? Are there subtle changes in logic, error handling, or signatures?
4. **Review new abstractions.** Are new classes, patterns, or indirections justified by the scope of change?
5. **Check test quality.** Do new tests actually test the right things? Are mocks appropriate?
6. **Flag pre-existing issues separately.** If you notice a pre-existing problem while reviewing, note it but clearly mark it as "pre-existing, not introduced by this PR/MR".

For each finding, record:
- **File and line number** (in the new code)
- **Description** of the issue
- **Severity** (your initial assessment -- will be discussed with user)
- **Pre-existing?** yes/no

**Codex review (parallel, MANDATORY):**

**Do NOT skip this step.** Always launch Codex for a second opinion, even if you are confident in your own review.

Check if Codex is installed:
```bash
which codex
```

If not installed, warn the user but continue with your own review. If available, launch Codex review in background while you do your own review:

```bash
CODEX_OUT="/tmp/codex-review-$(date +%s)-$$.jsonl"
# For GitHub:
codex exec review --base <BASE_BRANCH> --json > "$CODEX_OUT" 2>&1
# run_in_background: true, timeout: 360000
```

Do NOT wait for Codex before starting your own review. Run them in parallel.

### 7. Combine findings

After both reviews complete:

1. Parse Codex output (if available) -- extract the final `agent_message` from JSONL:
   - Find all lines with `"type":"agent_message"` in `item.completed` events
   - Use the last one as the final answer
   - Extract the `text` field

2. Merge findings:
   - If Codex found issues you missed, add them (attributed to Codex)
   - If Codex confirmed your findings, note the agreement
   - If Codex found nothing, note that too

3. Clean up Codex output file: `rm -f "$CODEX_OUT"`

### 8. Present findings summary

Present all findings as a numbered list:

```
## PR/MR Review: <title>

### Findings

1. [file.py:42] Description of finding
   Severity: <your assessment>
   Source: Claude / Codex / Both

2. [file.py:88] Description of finding (pre-existing)
   Severity: <your assessment>
   Source: Claude

3. ...

### Positive observations
- What's well-done in this PR/MR

### Codex verdict
> <Codex's summary if available, or "Codex not available">
```

### 9. Interactive finding-by-finding discussion

Go through each finding one at a time:

For each finding:
1. Present the finding in detail (show relevant code snippet)
2. State your severity assessment
3. Ask the user:
   - Do they agree with the severity? (they can adjust: e.g. "nit", "non-blocking", "blocking", or their own label)
   - Should this be posted as a comment? Options:
     - **Inline comment** on the specific file/line
     - **General PR/MR comment**
     - **Skip** (don't post)
4. If the user wants to post, show the exact comment text and ask for approval before posting
5. Post the comment only after explicit approval

**Posting inline comments:**

GitHub (use the reviews API for inline comments):
```bash
# Write review body to temp file
cat > /tmp/pr-review-comment.json << 'EOF'
{
  "event": "COMMENT",
  "comments": [
    {
      "path": "<file_path>",
      "line": <line_number>,
      "body": "<comment text>"
    }
  ]
}
EOF
gh api repos/<owner>/<repo>/pulls/<number>/reviews --input /tmp/pr-review-comment.json
rm -f /tmp/pr-review-comment.json
```

GitLab (use the discussions API for inline comments):
```bash
# Write comment to temp file for multi-line safety
cat > /tmp/mr-comment.md << 'EOF'
<comment text>
EOF
# For inline: use glab api to create a discussion with position
glab api projects/:id/merge_requests/<number>/discussions \
  --method POST \
  -f "body=$(cat /tmp/mr-comment.md)" \
  -f "position[base_sha]=<base_sha>" \
  -f "position[head_sha]=<head_sha>" \
  -f "position[start_sha]=<start_sha>" \
  -f "position[position_type]=text" \
  -f "position[new_path]=<file>" \
  -f "position[new_line]=<line>"
rm -f /tmp/mr-comment.md
```

**Posting general comments:**

GitHub:
```bash
# Write to temp file for multi-line safety
cat > /tmp/pr-comment.md << 'EOF'
<comment text>
EOF
gh pr comment <number> --body-file /tmp/pr-comment.md
rm -f /tmp/pr-comment.md
```

GitLab:
```bash
cat > /tmp/mr-comment.md << 'EOF'
<comment text>
EOF
glab mr comment <number> --body-file /tmp/mr-comment.md
rm -f /tmp/mr-comment.md
```

### 10. Cleanup

After all findings are processed, ask the user if they want to:
- Stay on the PR/MR branch (to inspect code)
- Return to their original branch

If returning:
```bash
git checkout <original_branch>
```

If a stash was created in step 2:
```bash
git stash pop
```

---

## Important rules

- **Never post a comment without explicit user approval.** Always show the exact text first.
- **Never assume the base branch.** Always detect it from the PR/MR metadata.
- **Focus on the diff.** Pre-existing issues should be clearly labeled as such.
- **One comment at a time.** Do not batch-post multiple comments.
- **Use temp files for comment bodies.** Never pass multi-line markdown via `--body` in shell.
- **Never merge or approve the PR/MR.** That is always a manual task.
- **Clean up temp files** after each comment is posted.

## Examples

### Review a specific PR
```
/review-pr 100
/review-pr https://github.com/org/repo/pull/100
```

### Review current branch's PR
```
/review-pr
```

### Review a GitLab MR
```
/review-pr 42
/review-pr https://gitlab.com/org/repo/-/merge_requests/42
```
