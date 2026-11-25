# Global instructions (all projects)

## Rules

- Treat Git as readonly. NEVER stage or unstage changes yourself. NEVER
  commit changes yourself. NEVER push changes yourself.
  - Staging is the user's review mechanism: staged = reviewed. Never
    touch it, and don't report on or worry about staging state (`MM`,
    index vs working drift, etc.).
  - Never pile several commits into the working tree. On a multi-commit
    plan, make one commit's changes, hand them off with a commit message,
    and wait for me to commit before starting the next.
- Never start the Docker daemon; only use it if already running.
- Keep the machine usable while you work: I use it at the same time,
  and unbounded test suites, builds and browsers fill RAM and swap and
  max the CPU. Before heavy jobs (test suites, builds, Playwright,
  browsers, databases), check the machine's cores, RAM and current
  load, then run them under `nice -n 15`, one at a time, with workers
  sized to leave room (never all cores), and never several production
  builds side by side. Stop the servers and browsers you start when
  done. Any agent you drive (e.g. Codex) gets the same rules in its
  prompt.
- Use the project's package manager to manipulate dependencies. NEVER
  change dependencies manually.
- A question gets an answer, not an edit. When I ask a question,
  including one that challenges something you did, answer in words:
  justify it with evidence or admit the mistake. NEVER edit, revert, or
  "fix" files in response to a question. Only change files on an
  explicit instruction; if my reply is ambiguous, ask what I mean.

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
