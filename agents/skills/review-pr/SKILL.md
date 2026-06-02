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

If there are uncommitted changes, **auto-stash without asking**:
```bash
git stash push -u -m "Pre-review stash (review-pr skill)"
```

Remember that a stash was created for cleanup in step 10.

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

### 4. Checkout the branch locally and sync with remote

```bash
git fetch origin <HEAD_BRANCH> <BASE_BRANCH>
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

**Always pull to sync the local branch with the remote.** Codex diffs the working tree against local HEAD, so if the local branch is behind the remote, Codex reviews the wrong diff:
```bash
git pull --ff-only origin <HEAD_BRANCH>
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
7. **Zoom out on complex PRs/MRs.** For non-trivial changes (new features, new abstractions, significant refactors), step back from line-level review and assess the change as a whole:
   - **Cohesion and structure.** Do the new functions/classes have clear, single responsibilities? Is related logic grouped sensibly?
   - **Fit in the codebase.** Does this follow existing patterns and conventions, or does it introduce a parallel way of doing the same thing? Does it belong where it was placed?
   - **Is this the best approach?** Consider whether a more elegant, efficient, or simpler design exists. If so, describe it concretely as a non-blocking suggestion rather than a vague "this could be better".
   - Keep this proportional: skip it for trivial diffs (typo fixes, config bumps, one-line changes).

For each finding, record:
- **File and line number** (in the new code)
- **Description** of the issue
- **Severity** (your initial assessment -- will be discussed with user)
- **Pre-existing?** yes/no

**Codex review (parallel, MANDATORY, LAUNCH FIRST):**

**Do NOT skip this step.** Always launch Codex for a second opinion, even if you are confident in your own review. **Launch Codex BEFORE starting your own review** so it runs in parallel. Do not do your own analysis first.

Check if Codex is installed:
```bash
which codex
```

If not installed, warn the user but continue with your own review. If available, launch Codex review in background while you do your own review:

```bash
CODEX_OUT="/tmp/codex-review-$(date +%s)-$$.jsonl"
# For GitHub:
codex exec review --base origin/<BASE_BRANCH> --json > "$CODEX_OUT" 2>&1
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

**CRITICAL: GitLab inline comments require precise diff positioning or they silently fall back to general comments.**

Before posting, you MUST determine the correct position parameters:

1. **Get the diff SHAs** from the MR versions endpoint (do this once per review, cache the values):
   ```bash
   glab api projects/<url-encoded-project>/merge_requests/<number>/versions \
     | python3 -c "
   import json, sys
   v = json.load(sys.stdin)[0]
   print('base_sha:', v['base_commit_sha'])
   print('head_sha:', v['head_commit_sha'])
   print('start_sha:', v['start_commit_sha'])
   "
   ```

2. **Determine `old_path` and line parameters** based on the file status:
   - **New file** (entire file is added in the diff):
     - `old_path` = same as `new_path`
     - Use `new_line` only (do NOT set `old_line`)
   - **Modified file** (commenting on an added/changed line):
     - `old_path` = same as `new_path` (unless file was renamed)
     - Use `new_line` only for added lines (lines starting with `+` in the diff)
   - **Modified file** (commenting on a removed line):
     - Use `old_line` only for removed lines (lines starting with `-` in the diff)
   - **Renamed file**:
     - `old_path` = path before rename, `new_path` = path after rename

3. **Verify the target line appears in the diff.** GitLab can only place inline comments on lines that are part of the diff context (added, removed, or context lines shown in the diff hunks). If the line is outside the diff context, post as a general comment instead and mention the file and line number in the body.

4. **Get the correct line number from the diff**, not from the file. Run:
   ```bash
   git diff origin/<BASE_BRANCH>...origin/<HEAD_BRANCH> -- <file_path> | grep -n "^[+-]" | head -40
   ```
   Cross-reference the diff hunk headers (`@@ -old_start,count +new_start,count @@`) to confirm the `new_line` matches the actual diff position.

**CRITICAL: You MUST use `--input` with `-H "Content-Type: application/json"` and a JSON file. Do NOT use `-f` flags for position fields.** The `-f` flag sends form-encoded data which does not properly nest the `position` object, causing GitLab to silently drop the position and create a general comment instead.

```bash
# Write the JSON payload to a temp file
cat > /tmp/mr-inline-comment.json << 'ENDJSON'
{
  "body": "<comment text>",
  "position": {
    "base_sha": "<base_sha>",
    "head_sha": "<head_sha>",
    "start_sha": "<start_sha>",
    "position_type": "text",
    "old_path": "<file>",
    "new_path": "<file>",
    "new_line": <line_number>
  }
}
ENDJSON
# Post with JSON content type
glab api projects/<url-encoded-project>/merge_requests/<number>/discussions \
  --method POST \
  --input /tmp/mr-inline-comment.json \
  -H "Content-Type: application/json"
rm -f /tmp/mr-inline-comment.json
```

**Verify the response:** The note `type` must be `"DiffNote"`. If it is `"DiscussionNote"`, the position was silently dropped and it landed as a general comment.

**Common mistakes that cause inline comments to land as general comments:**
- Using `-f` flags instead of `--input` with JSON (the #1 cause)
- Missing `old_path` (required even for new files)
- Using a line number that is outside the diff hunks
- Wrong SHAs (always fetch from the versions endpoint, never compute manually)
- Using `new_line` for a deleted line (use `old_line` instead)

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
