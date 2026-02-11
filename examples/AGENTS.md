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
