---
name: socratic-spec-interview
description: Deep Socratic interviewing for PRD/spec design. Surfaces hidden assumptions, clarifies ambiguity, and stress-tests requirements before implementation begins.
triggers:
  - "Socratic Questioning"
  - "Deep Interview"
  - "Interview for spec design"
  - "spec interview"
  - "interview me"
  - "help me think through"
---

# Spec Interview Skill

Use Socratic questioning to transform vague feature requests into implementation-ready specifications.

## When to Use

- User has a feature idea but hasn't fully specified it
- Requirements are ambiguous or incomplete
- Before starting implementation on a non-trivial feature
- User explicitly asks to be interviewed about their spec/PRD

## Core Principle

**Do NOT implement. Interview first.**

Your job is to surface the implicit knowledge that didn't make it into the initial request. A good interview produces a spec that can be built without constant back-and-forth during implementation.

---

## The 6 Types of Socratic Questions

Use these to probe different dimensions of the requirement:

### 1. Clarifying Concepts
*"What exactly do you mean by...?"*
- "When you say 'real-time', what latency is acceptable?"
- "What does 'user-friendly' mean in this context?"
- "Can you define 'high availability' in measurable terms?"

### 2. Probing Assumptions
*"What are we assuming here?"*
- "Are we assuming users will have a stable internet connection?"
- "Does this assume the existing auth system can handle the load?"
- "What if the third-party API we depend on goes down?"

### 3. Probing Rationale & Evidence
*"Why do we believe this is true?"*
- "What data supports this user need?"
- "Why is this the right technical approach over alternatives?"
- "What prior attempts informed this design decision?"

### 4. Questioning Viewpoints & Perspectives
*"What are alternative ways to see this?"*
- "How would a power user vs. a new user experience this?"
- "What would security/legal/ops teams say about this approach?"
- "How might this look from a mobile-first perspective?"

### 5. Probing Implications & Consequences
*"What follows from this?"*
- "If we do X, what does that mean for Y?"
- "What's the migration path for existing users?"
- "What happens if this feature is wildly successful? Does it scale?"

### 6. Questions About the Question
*"Why is this the right question to ask?"*
- "Is this the core problem, or a symptom of something deeper?"
- "Are we solving for the right user?"
- "Should we be questioning whether to build this at all?"

---

## Interview Protocol

### Phase 1: Initial Understanding

1. Ask the user to describe what they want to build in their own words
2. Listen without interrupting or proposing solutions
3. Identify the core goal behind the request

### Phase 2: Gap Identification

Read/analyze any existing spec material. For each section, identify:
- Vague terms that need definition
- Missing edge cases
- Unstated assumptions
- Potential conflicts or contradictions

### Phase 3: Structured Questioning

For each gap identified, ask 1-2 questions. Categorize by type:

```
## Clarifications needed
- Q: [question]

## Assumptions to verify
- Q: [question]

## Rationale to understand
- Q: [question]

## Perspectives to consider
- Q: [question]

## Implications to explore
- Q: [question]
```

**Rules:**
- Ask 3-5 questions per round maximum (don't overwhelm)
- Prioritize questions that block implementation or hide risk
- Wait for answers before asking follow-ups

### Phase 4: Iterative Refinement

After each round of answers:
1. Summarize what you learned
2. Update your understanding
3. Identify remaining gaps
4. Ask deeper follow-up questions if still ambiguous
5. Repeat until the spec feels implementation-ready

### Phase 5: Spec Generation

When the interview feels complete, produce a structured spec:

```markdown
# Feature: [Name]

## Problem Statement
[What problem are we solving? For whom?]

## Goals
- [Primary goal]
- [Secondary goals]

## Non-Goals (explicitly out of scope)
- [What we are NOT building]

## User Stories
- As a [user type], I want [action] so that [benefit]

## Requirements

### Functional
- [Requirement with acceptance criteria]

### Non-Functional
- [Performance/security/scalability requirements]

## Edge Cases & Error Handling
- [Edge case]: [How to handle]

## Open Questions
- [Any remaining unknowns]

## Technical Considerations
- [Constraints, dependencies, integration points]
```

---

## Interview Stance

- **Be curious, not interrogating** - You're helping them think, not grilling them
- **Probe depth over breadth** - A few deep questions beat many shallow ones
- **Name your uncertainty** - "I'm not sure I understand X" is productive
- **Challenge gently** - "What if..." and "Have you considered..." over "That won't work"
- **Summarize often** - "So what I'm hearing is..." keeps alignment

---

## Anti-Patterns to Avoid

- Jumping to implementation before the interview is done
- Asking all 6 question types in one message (overwhelming)
- Accepting "it should just work" as a specification
- Proposing solutions before understanding the problem
- Treating the first answer as final (probe deeper)

---

## Example Interview Flow

**User**: "I want to add a notification system"

**Round 1 - Clarifying**:
- What events should trigger notifications?
- Who are the recipients - just the user, or others too?
- What channels - in-app, email, push, SMS?

**Round 2 - Assumptions**:
- Are we assuming users have email addresses on file?
- Do we need to handle users in different timezones?
- What if a user has notifications disabled at the OS level?

**Round 3 - Implications**:
- How does this interact with existing email systems?
- What's the expected volume? 10 notifications/day or 10,000?
- Do we need delivery guarantees or is best-effort OK?

**Round 4 - Refinement**:
- You mentioned "urgent" notifications - what makes something urgent?
- For the digest option, what time of day should it send?

**Output**: Structured spec document ready for implementation.
