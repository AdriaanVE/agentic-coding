---
name: jira-ticket
description: Draft the body text of a Jira ticket from provided context, following a fixed user-story layout. Use when asked to "create a jira ticket", "write a jira ticket", "jira ticket body", or "/jira-ticket".
---

# Claude Code Skill: Jira Ticket Body

Produce the **body text** of a Jira ticket from context the user provides, in the exact layout below. Output text only, formatted for copy-paste into Jira. Do not create, post, or transmit the ticket anywhere.

## When to use

Trigger phrases: "create a jira ticket", "write a jira ticket", "make a jira ticket", "jira ticket body", "/jira-ticket".

The user will present context for a new ticket for a team member (a feature, a follow-up, a bug, a chore). Turn that into a single well-formed ticket body.

## Output layout (always exactly this)

```
**Title**: [...]

**As a** [role]

**I would like** [...]

**In order to** [...]


**Context:**
[...]


**Acceptance Criteria:**
[...]


**Blocked by:**
[...]
```

Reproduce the field labels, bolding, and spacing exactly (note the double blank lines before **Context:**, **Acceptance Criteria:**, and **Blocked by:**).

## Field rules

**Title** — short, specific, imperative. No project key prefix unless the user gives one.

**As a [role]** — pick the single best-fitting role from this fixed list, inferred from the context:
`Data Scientist, Data Strategist, Cloud Engineer, Devops Engineer, Tech Lead, Data Analyst, GenAI Engineer, Administrator`
State the inferred role and let the user override. Do not invent roles outside this list.

**I would like** — the goal, phrased as the desired capability or change.

**In order to** — the business or technical reason. "As a / I would like / In order to" should read as one coherent user story.

**Context** — the why and where: relevant systems, files, links, current state, and what is already true. Include file paths, line numbers, config keys, and URLs from the provided context when they help an engineer act. Keep it proportional: simple tickets get a short context, do not pad.

**Acceptance Criteria** — a short bullet list of independently verifiable checks. Each criterion must be testable on its own (a reviewer can mark it pass/fail), not a restatement of the goal. Prefer concrete, observable outcomes ("X is configured in `file:line`", "a benchmark run shows no regression vs baseline", "served responses confirmed in traces") over vague intent ("X works", "X is improved"). Keep the list tight; do not over-specify. Simple tickets may have two or three criteria.

**Blocked by** — only populate if the context names a blocker. Otherwise write `None`.

## Process

1. Read the provided context.
2. If anything required is missing or ambiguous, **ask targeted clarifying questions before drafting** (use the AskUserQuestion tool). Required to draft well:
   - the goal (what capability/change) and the reason (in order to ...),
   - enough context for an engineer to act,
   - at least the basis for one or two verifiable acceptance criteria.
   Do not ask about **Blocked by**; default it to `None` when unspecified.
   Do not block on role: infer it and let the user correct it.
3. Draft the ticket in the layout above.
4. Present the role you inferred so the user can override it.

## Style

- Follow the global writing rules: no em dashes, no emojis, describe things by what they are. Use commas, periods, or semicolons.
- Be concise. Do not be verbose where the ticket does not need it. Simple tickets exist and should stay simple.
- Acceptance criteria read as checks, not goals.

## Example

Context given: "PR #259 adds a gpt-4.1/gpt-5.5 generation switch to the local benchmark only. Production reads the model from `OPENAI_MODEL_NAME` (`main.yml:9` = `openai_gpt_4.1_telenet`) via `service.py:67`, so merging does not change production. To ship gpt-5.5 the model must change in `main.yml` and in the OneAI dashboard (https://ui.telenet.dev.oneai.libertyglobal.com/one-ai/dashboard)."

Output:

```
**Title**: Switch deployed RAG generation model to GPT-5.5 (main.yml + OneAI dashboard)

**As a** Devops Engineer

**I would like** to switch the deployed RAG agent's generation model to GPT-5.5 in both the deploy manifest and the OneAI dashboard

**In order to** serve customers with the model we validate offline, instead of leaving production on GPT-4.1


**Context:**
PR #259 adds a GPT-4.1 / GPT-5.5 switch to the local benchmark graph only. Production resolves its model from `OPENAI_MODEL_NAME`, read by `BaseOneAIChatModel` in `src/rag_agent/service/service.py:67`, fixed to `openai_gpt_4.1_telenet` in `main.yml:9` (and the related `OPENAI_CHAT_MODEL` / `OPENAI_PRIMARY_MODEL_NAME` / `OPENAI_SECONDARY_MODEL_NAME` keys). Merging #259 does not change the served model. The model must be updated in two places that feed the deployed agent: `main.yml` and the OneAI dashboard agent config (https://ui.telenet.dev.oneai.libertyglobal.com/one-ai/dashboard).


**Acceptance Criteria:**
- `OPENAI_MODEL_NAME` and the related model keys in `main.yml` are set to the GPT-5.5 gateway model, consistently.
- The same model is set in the OneAI dashboard agent config, with no drift from `main.yml`.
- A deployed-agent trace confirms responses are generated by GPT-5.5 (not just config).
- A documented rollback to `openai_gpt_4.1_telenet` exists.


**Blocked by:**
GPT-5.5 availability on the OneAI gateway for the deployed agent must be confirmed.
```
