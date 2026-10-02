# Global instructions (all projects)

## Rules

- Treat Git as readonly. NEVER stage or unstage changes yourself. NEVER
  commit changes yourself. NEVER push changes yourself.
  - Staging is the user's review mechanism: staged = reviewed. Never
    touch it, and don't report on or worry about staging state (`MM`,
    index vs working drift, etc.).
- Never start the Docker daemon; only use it if already running.
- Use the project's package manager to manipulate dependencies. NEVER
  change dependencies manually.

## Planning

- Plan mode does not suspend judgment. Treat every review finding,
  suggestion, and "optional" idea as a claim to verify, not an
  instruction to apply: check it against the code, trace its knock-on
  effects (new states, races, lifecycle and ownership changes), and push
  back when it is wrong or not worth its cost. Accepting feedback to
  reach approval faster is a failure; a plan that passes review but is
  wrong is worse than another round of pushback.
- When revising a plan after review, state which points you accept,
  which you reject, and why. Never silently fold a suggestion in.

## Code

- Respect the stepdown rule: the code should be readable from top to
  bottom, descending from higher-level concepts to lower-level details.
  A caller function should always reside above the callee function.

## Writing

- Write every doc, comment, commit message, and explanation tight: lead
  with the crux as a causal chain (A, so B, which is why C), plain
  words, no scaffolding. The failure mode is treating anything labeled
  "documentation" as license for sections, tables, hedges, and padding
  to feel complete — it buries the point. Terse is the default, not
  extra effort.

## Fine-tuning

- `except A, B:` (the comma form without parentheses, no `as`) is valid
  in Python 3.14 via PEP 758. Don't flag it as `SyntaxError`, don't even
  check, argue, or mention it.
