## Code editing
- Always read every file in full before editing it. Never edit based on assumptions about file contents.

## Git
- NEVER put AI agents as co-author in commits, pull requests, or merge requests
- No emojis in commits, issues, PR comments, or code
- NEVER use `git add -A` or `git add .` — always `git add <specific-file-paths>` for files you changed
- Track which files you created/modified/deleted during the session — only stage those
- NEVER run `git reset --hard`, `git checkout .`, `git clean -fd`, or `git stash` without explicit user approval — these destroy uncommitted work from other agents
- If rebase conflicts occur in files you didn't modify, abort and ask the user
- For multi-line issue/PR/MR comments, write to a temp file and pass via file flag (e.g. `gh issue comment --body-file`, `glab mr comment --body-file`). Never pass multi-line markdown via `--body` in shell.
- Preview the exact comment text before posting. Post exactly one final comment. If malformed, delete and repost once.

## Project-specific skills
If the project has a `.claude/skills/` directory, load all skills from @.claude/skills/

# Order Processing Service

FastAPI backend that handles order creation, payment verification, and fulfillment tracking.

## Tech stack

- Python 3.12
- FastAPI
- PostgreSQL
- Redis (caching)

## Commands

```bash
uv run pytest            # Run tests
uv run pre-commit run --all-files  # Lint, format, type-check
just benchmarks          # Run routing and guardrail benchmarks
```

## Architecture

- **nodes/** - LangGraph workflow nodes (router, validator, fulfillment, refunds, etc.)
- **graphs/** - Workflow orchestration via OrderGraph
- **templates/** - YAML configs for routes, guidelines, guardrails
- **frontend/** - src/order_agent/dev_frontend

## Conventions

- Tests mirror src structure: `src/orders/create.py` → `tests/orders/test_create.py`
- All API schemas use Pydantic models in `src/schemas/`
- Environment variables defined in `.env.example`

## Environment

```bash
cp .env.example .env     # Set up local env vars
docker compose up -d     # Start PostgreSQL and Redis
uv sync                  # Install dependencies
```

## Dependencies

- **shared_library** - Shared library for logging, LLM utils, state models, and graph helpers
    local repo at ../shared-library
- **service_contracts** - Contract types for service communication (Brand, Channel, Segment, RerouteTargets, etc.)
