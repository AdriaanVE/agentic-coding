---
name: brain
description: Interact with the personal Obsidian knowledge base at ~/Brain. Look up, create, and update notes, TILs, ideas, and project documentation.
---

# Brain — Personal Knowledge Base

Interact with the user's Obsidian vault at `~/Brain`.

## When to use

- User asks to save a note, TIL, idea, or learning
- User wants to find or read notes from their knowledge base
- User asks to update project notes or link a repo
- User mentions "brain", "vault", "notes", or "obsidian"

## Vault structure

| Folder | Purpose |
|--------|---------|
| `projects/` | Active project notes. Each project gets a subfolder with a MOC note. |
| `dev/` | Developer knowledge — snippets, repo reference notes (`dev/repos/`). |
| `learning/` | Books, courses, articles, TILs. |
| `ideas/` | Brainfarts, hobby explorations, loose thoughts. |
| `inbox/` | Unprocessed quick capture. |
| `weekly/` | Weekly review notes (`YYYY-Www.md`). |
| `archive/` | Completed/dormant projects and old notes. |
| `_templates/` | Obsidian note templates (reference only — do not modify). |
| `_attachments/` | Images, PDFs, screenshots. |
| `agents/` | Shared agentic knowledge — skills, prompts, workflows. |

## Conventions

- **Date format**: `YYYY-MM-DD` everywhere
- **Links**: Use `[[wikilinks]]` for internal links between notes
- **Tags**: `#status/draft`, `#status/active`, `#status/done` for note status
- **Type tags**: `#type/til`, `#type/idea`, `#type/project`, `#type/repo`
- **Project notes**: Each project folder has a MOC named after the project (e.g., `projects/foo/foo.md`)
- **Repo references**: `dev/repos/` has lightweight notes linking to local repo paths
- **Max folder depth**: 2 levels. Use links and MOCs instead of deeper nesting.

## Templates

When creating notes, use these frontmatter patterns:

### TIL (save to `learning/`)
```markdown
---
created: YYYY-MM-DD
tags:
  - type/til
---

# TIL: <title>

<content>
```

### Idea (save to `ideas/`)
```markdown
---
created: YYYY-MM-DD
tags:
  - type/idea
---

# <title>

<content>
```

### Project MOC (save to `projects/<name>/<name>.md`)
```markdown
---
status: active
created: YYYY-MM-DD
tags:
  - type/project
---

# <title>

## Overview
## Repo
- **Local path**: `~/Code/<name>`
- **Remote**:
- **Tech stack**:
## Key Decisions
## Related
```

### Repo reference (save to `dev/repos/`)
```markdown
---
created: YYYY-MM-DD
tags:
  - type/repo
---

# <title>

## Details
- **Local path**: `~/Code/<name>`
- **Remote**:
- **Tech stack**:
- **Status**: active

## Description
## Related Projects
```

## Looking up notes

- **By topic**: Grep for keywords across `~/Brain` (exclude `_attachments/`, `.obsidian/`)
- **By type**: Grep for tag in frontmatter, e.g. `type/til`, `type/project`, `type/repo`
- **By status**: Grep for `status/active`, `status/draft`, `status/done`
- **By folder**: List or glob the relevant folder (e.g., `~/Brain/projects/*/` for all projects)
- **By file name**: Glob with `~/Brain/**/<pattern>.md`
- **Follow wikilinks**: When a note contains `[[some-note]]`, find that note with Glob and read it
- **Project lookup**: Check `projects/<name>/<name>.md` for the MOC, then follow links from there
- **Repo lookup**: Check `dev/repos/` for repo reference notes that contain local paths and tech stack info

## Instructions

- Always read existing notes before modifying them
- Use the correct template when creating new notes
- Use today's date for `created` fields
- File names: lowercase, kebab-case (e.g., `my-new-idea.md`)
- When unsure where a note belongs, put it in `inbox/`
- When saving a TIL from a coding session, include concrete examples
