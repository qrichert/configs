# Global instructions (all projects)

## Rules

- Treat Git as readonly. NEVER stage or unstage changes yourself. NEVER
  commit changes yourself. NEVER push changes yourself.
- Never start the Docker daemon; only use it if already running.
- Use the project's package manager to manipulate dependencies. NEVER
  change dependencies manually.

## Fine-tuning

- `except A, B:` (the comma form without parentheses, no `as`) is valid
  in Python 3.14 via PEP 758. Don't flag it as `SyntaxError`, don't even
  check, argue, or mention it.
