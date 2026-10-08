---
name: issue-resolution-workflow
description: Resolve a complex tracked issue through investigation, a reviewed plan, explicit implementation approval, scoped changes, validation, and final diff review. Use when an issue needs coordinated code or architecture work with minimal manual steering.
---

# Issue Resolution Workflow

Resolve one issue at a time. Use the issue and its discussion as the record of
the requested outcome, then verify their claims against the current code. Keep
the maintainer involved for decisions that cannot be inferred safely and for
approval of the implementation plan; handle the remaining investigation,
planning, validation, and review without routine check-ins.

## Model Selection and Delegation

When model selection and delegation are available, prefer a stronger
model for investigation synthesis, planning, and independent plan and
diff reviews. Use a smaller capable model for bounded investigation and
mechanical implementation of an explicitly approved plan, including its
focused tests. Give the implementer the canonical plan, applicable
instructions, and locked scope; return new architectural or product
decisions to the planning model. The implementer must not serve as its
own independent reviewer. Choose models by task difficulty and available
capabilities rather than hard-coded model names.

## Investigate the Issue

1. Identify the repository and issue from the request. If either is ambiguous,
   inspect the available context and ask only if multiple plausible targets
   remain. Read the full issue body and discussion, applicable `AGENTS.md`, and
   relevant current code. Refresh these sources when resuming in a new chat.
2. Establish the observable problem, acceptance criteria, affected behavior,
   and current owner of the relevant invariant. Check whether the issue is
   already solved, obsolete, duplicated, based on a false premise, or aimed at
   the wrong ownership boundary. An open issue is evidence of a request, not
   proof that a code change is needed.
3. If no implementation is warranted, explain the evidence and recommended
   disposition. Do not manufacture a diff. Change the issue's status or content
   only when authorized.

Read-only inspection needs no extra confirmation. Do not edit, comment on,
close, reopen, or reorder tracked issues unless the user's authorization covers
that external mutation.

## Plan the Resolution

Write a canonical plan at `~/.codex/plans/issue-<id>-<descriptive-slug>.md`.
For a tracker without a numeric ID, use its stable issue key. Include:

- Goal, acceptance criteria, and the evidence from the issue and current code.
- Locked scope, intended behavior, invariant owner, and meaningful tradeoffs.
- Concrete changes by file and symbol, including migration, concurrency,
  compatibility, and failure semantics where relevant.
- Focused tests, affected compatibility checks, lint or other validation,
  risks, and explicit non-goals.
- Review decisions and concrete reasons for declining actionable findings.

Make ordinary implementation choices in the plan. Ask for an earlier product or
architecture decision only when it cannot be inferred safely. For a substantive
plan, use an independent reviewer when delegation is available and authorized.
Have the reviewer read the issue, applicable instructions, and current code
before the plan, then assess correctness, scope, design, migration, and
validation. Resolve actionable findings and update the plan. Do not treat the
plan's stated intent as evidence that a potential regression is acceptable.

Explain the proposed resolution in plain language, give the plan path, and wait
for explicit approval before implementing. A question, correction, or objection
is not implementation approval. Update the canonical plan when an approved
decision changes.

## Implement and Validate

Follow the approved plan within its locked scope. Preserve unrelated work.
Never stage, unstage, commit, push, revert, or discard the maintainer's work.
If the code reveals a conflicting internal API, wrong ownership boundary,
unexpected scope expansion, or a new product decision, stop the affected work,
explain the finding, and revise the plan or seek a decision before proceeding.
Reassess whether implementation remains warranted when new evidence appears.

For a bug, add a focused regression test first when practical and useful. Run
validation proportionate to the change: narrow tests, compatibility checks
implied by the diff, then affected lint or type checks. Report exact commands
and results. Broaden testing only for a concrete remaining risk or required
gate.

## Review and Hand Off

Review the uncommitted diff against the issue, current code, and approved plan.
For a substantive change, use an independent reviewer when delegation is
available and authorized. Have that reviewer inspect the issue discussion,
applicable instructions, diff, and surrounding code before reading the plan.
Prioritize bugs, regressions, invariant violations, missing tests, scope drift,
and misleading documentation. Fix valid findings and rerun relevant validation.
Record concrete reasons for declined findings in the plan. A plan cannot by
itself justify a user-visible failure or weakened invariant.

Hand off the outcome, important decisions, exact files changed, validation
commands and results, remaining risks, and a suggested commit message if
useful. Leave staging and committing to the maintainer. Close or update the
issue only when its completion criteria are met and the user has authorized
that tracker change.

## Multiple Issues

Apply this entire process to each issue in sequence, with a separate plan and
review for each. Use the user's stated order or the tracker's explicit order;
ask if the order remains ambiguous. Do not start the next issue while the
previous change cannot be isolated safely. Parent issues and sub-issue queues
are optional tracker context, not prerequisites for this workflow.
