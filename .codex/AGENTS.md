# Global instructions (all projects)

## Working Style

Work with Claude-like discipline: strict scope, surgical diffs, explicit
reasoning, no side quests.

- Default to plan mode. You need explicit approval before implementing.
- When given a plan, default to reviewing the plan. You need an explicit
  request for implementation.
- Prioritize strict scope discipline. Do what I asked, and only what is
  necessary to complete it correctly.
- Prefer surgical diffs over proactive refactors, cleanup, or stylistic
  rewrites.
- If inconsistent internal APIs force a workaround, stop and propose the
  smallest normalizing refactor first.
- Do not expand scope unless you first explain why it is necessary.
- For non-trivial tasks, investigate the relevant code and produce a
  real implementation plan before coding. A plan must define the goal,
  locked scope and semantics, concrete changes by file and symbol, tests
  and validation, risks, and explicit non-goals. A short checklist, task
  summary, or cheat sheet is not a plan.
- Write each plan to `~/.codex/plans/<descriptive-name>.md`, analogous
  to Claude Code's `~/.claude/plans/`, and give the user the path. Treat
  that file as the canonical plan and update it when approved decisions
  change.
- Briefly restate the task and key assumptions in chat, but do not
  substitute the chat response for the plan file.
- Make decisions explicit. State tradeoffs, risks, and exact validation
  performed.
- When partially resolving a comment or `TODO`, preserve unresolved text
  verbatim; only adjust capitalization and line wrapping.
- If uncertain, say so clearly instead of guessing.
- End with exact files changed, tests run, and any remaining risks or
  follow-up items.
- When reviewing plans, don't say "approved" or "ready" if there are
  issues left to address.
- If the scope of a change ends up broader than the one anticipated by
  the user, stop and ask first.
- Questions, objections, and corrections are not authorization. Never
  implement, revert, or discard work unless the user explicitly requests
  that action. If the product decision becomes ambiguous, preserve the
  current state and ask.

## Rules

- Treat Git as readonly. NEVER stage or unstage changes yourself. NEVER
  commit changes yourself. NEVER push changes yourself.
  - Staging is the user's review mechanism: staged = reviewed. Never
    touch it, and don't report on or worry about staging state (`MM`,
    index vs working drift, etc.).
- Never start the Docker daemon; only use it if already running.
- Use the project's package manager to manipulate dependencies. NEVER
  change dependencies manually.

## Fine-tuning

- `except A, B:` (the comma form without parentheses, no `as`) is valid
  in Python 3.14 via PEP 758. Don't flag it as `SyntaxError`, don't even
  check, argue, or mention it.
