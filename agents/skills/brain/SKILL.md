---
name: brain
description: Interact with the personal Obsidian knowledge base at ~/Brain. Look up, create, and update notes, TILs, ideas, and project documentation.
---

# Brain — Personal Knowledge Base

Obsidian vault at `~/Brain`.

## Vault structure

| Folder | Purpose |
|--------|---------|
| `projects/` | Active project notes. Each project gets a subfolder with a MOC. |
| `dev/` | Developer knowledge — snippets, repo references (`dev/repos/`). |
| `learning/` | Books, courses, articles, TILs. |
| `ideas/` | Loose thoughts, hobby explorations. |
| `inbox/` | Unprocessed quick capture. |
| `weekly/` | Weekly review notes (`YYYY-Www.md`). |
| `archive/` | Completed/dormant projects and old notes. |
| `_templates/` | Note templates (reference only — do not modify). |
| `_attachments/` | Images, PDFs, screenshots. |
| `agents/` | Shared agentic knowledge — skills, prompts, workflows. |

## Conventions

- **Date format**: `YYYY-MM-DD`
- **Links**: `[[wikilinks]]` for internal links
- **Status tags**: `#status/draft`, `#status/active`, `#status/done`
- **Type tags**: `#type/til`, `#type/idea`, `#type/project`, `#type/repo`
- **Project MOCs**: `projects/<name>/<name>.md`
- **Repo references**: `dev/repos/<name>.md` — lightweight notes with local paths and tech stack
- **Max folder depth**: 2 levels. Use links and MOCs instead of deeper nesting.
- **File names**: lowercase, kebab-case (e.g., `my-new-idea.md`)

## Reading notes

- **By topic**: Grep for keywords across `~/Brain` (exclude `_attachments/`, `.obsidian/`)
- **By type**: Grep for frontmatter tag, e.g. `type/til`, `type/project`
- **By status**: Grep for `status/active`, `status/draft`, `status/done`
- **By folder**: List or glob the relevant folder (e.g., `~/Brain/projects/*/`)
- **By file name**: Glob with `~/Brain/**/<pattern>.md`
- **Follow wikilinks**: When a note contains `[[some-note]]`, glob for that file and read it
- **Project lookup**: Start at `projects/<name>/<name>.md`, follow links from there
- **Repo lookup**: Check `dev/repos/` for repo reference notes

## Writing notes

- Always read existing notes before modifying them
- Read the template from `~/Brain/_templates/` before creating a note
- Use today's date for `created` fields
- When unsure where a note belongs, put it in `inbox/`

| Template | Save to | Use for |
|----------|---------|---------|
| `til.md` | `learning/` | Things learned during coding/research |
| `idea.md` | `ideas/` | Brainfarts, explorations |
| `project.md` | `projects/<name>/<name>.md` | New project MOC |
| `repo.md` | `dev/repos/` | Repo reference note |

## TODO

`~/Brain/TODO.md` is a simple checklist for tracking tasks and action items.

- Read it when asked about tasks, TODOs, or what needs doing
- Add items with `- [ ] description`
- Mark done with `- [x] description`
- Keep it flat — no categories or priorities unless asked
