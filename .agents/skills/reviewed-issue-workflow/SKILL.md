---
name: reviewed-issue-workflow
description: Work through an ordered GitHub parent issue one child at a time using plain-language steering, a canonical reviewed plan, explicit approval, scoped implementation, independent diff review, and maintainer-owned commits. Use when continuing a tracked issue queue or when the user asks to churn through issues with review gates.
---

# Reviewed Issue Workflow

Treat the GitHub parent issue as the durable queue and each child issue as an
independent change. Do not keep a second local ordering document.

## Resume the Queue

1. Resolve the current repository and parent issue from the user's prompt.
   When none is named, inspect open issues with sub-issues. Use the only
   unambiguous workflow tracker; ask if multiple candidates remain.
2. Read the entire parent body and discussion, then fetch its ordered
   sub-issues from GitHub. The first open child is next unless a durable parent
   comment records a block or approved reorder.
3. Read the entire child discussion and inspect the current implementation.
   Reload both on every new chat instead of trusting remembered code details.
4. Do not start the next child while the previous change is uncommitted or the
   worktree is otherwise not clean enough to isolate one issue safely. Never
   stage, unstage, commit, push, revert, or discard user work.

Read-only GitHub and repository inspection needs no extra confirmation. Edit,
comment, close, reopen, add, or reorder issues only when the user's current
authorization covers that external mutation.

## Explain Before Planning

First reassess whether the issue should be implemented at all. An open issue
is a hypothesis, not an instruction to manufacture a diff. Recommend rejecting
or closing it as a no-op when current evidence shows it is obsolete, already
solved, duplicated, based on a false premise, aimed at the wrong ownership
boundary, or disproportionate to its actual benefit. Make the evidence and
preferred disposition explicit, then wait for the user's authorization before
changing GitHub state.

Repeat this check whenever planning, implementation, or review reveals new
evidence. Stop rather than completing an approved plan that has become wrong;
return to plain-language steering and explain whether the issue should be
rejected, narrowed, decomposed, or redesigned.

Before writing a plan, explain in plain language:

- What is observably wrong or structurally unsafe.
- Which boundary currently owns the invariant and why that ownership fails.
- The proposed owner and repair.
- User-visible behavior changes, meaningful tradeoffs, and explicit
  non-goals.
- Any product or architecture decision that cannot be inferred safely.

Keep this explanation concrete and cite the current code or issue discussion.
Then stop for initial steering. A question, correction, or objection is not
approval to write the plan or implement.

## Write and Review the Plan

After the user confirms the direction, write the canonical plan to

`~/.codex/plans/issue-<number>-<descriptive-slug>.md`.

The plan must contain:

- Goal and acceptance criteria.
- Locked scope and semantics.
- Current-code findings and the chosen invariant owner.
- Concrete changes by file and symbol.
- Migration, concurrency, compatibility, and failure semantics when relevant.
- Focused and compatibility tests, then affected-module lint commands.
- Risks, rollout or data handling, and explicit non-goals.
- Review decisions, including the rationale for declined findings.

Run an independent plan review in a fresh-context subagent. Give it the
repository path, child issue, and plan path, but require this review order:

1. Read the applicable `AGENTS.md`, raw issue discussion, and relevant current
   code, then form provisional findings without opening the plan.
2. Read the plan afterward to evaluate intended scope, semantics, and recorded
   decisions against those independently formed findings.

The plan explains intent; it must not pre-bias discovery. Do not discard a
correctness, regression, or invariant finding merely because the plan declares
the behavior intentional. An accepted user-visible failure or weakened
invariant requires concrete justification and explicit maintainer approval.
Instruct the reviewer to make no edits and report only actionable correctness,
scope, design, migration, and validation findings. Do not seed it with
suspected findings or the intended verdict.

Resolve every actionable finding and repeat with a fresh-context review until
clean. Incorporate valid findings. When declining a finding, put the concrete
rationale in the plan before the next review so the decision is reviewable and
does not recur without new evidence. Preferences without correctness or scope
impact are not blockers.

After three review rounds, explicitly reassess whether the repeated findings
expose a wrong ownership boundary. If so, pause and escalate the architecture
decision instead of polishing the same design indefinitely.

When the plan is clean, give the user its path and wait for explicit plan
approval. Do not implement before that approval.

## Implement the Approved Issue

Once approved, implement immediately and only within the approved child issue.
Preserve unrelated work. If implementation reveals a broader scope, a
conflicting internal API, or a new product decision, stop and return to the
plan rather than improvising.

For a bug, add a focused regression test first when practical. Run validation
in this order:

1. The narrowest relevant tests.
2. The targeted compatibility surface implied by the diff.
3. The affected module's lint command.

Do not run a module's full suite for each issue. Full suites are milestone
validation: targeted tests remain mandatory per change, and regressions found
at a milestone are fixed there. Do not run unrelated module suites merely for
ceremony.

## Review the Uncommitted Diff

After implementation and validation, run an independent fresh-context review
of the uncommitted change. Give the reviewer the repository path, issue, clean
plan, and validation results, but require this review order:

1. Read the applicable `AGENTS.md` and raw issue discussion, inspect the actual
   diff and surrounding code, and form provisional findings without opening
   the plan.
2. Read the plan afterward to check scope, intended semantics, and prior
   decisions against those independently formed findings.

The plan may explain or resolve a provisional finding, but it is not evidence
that a bug is acceptable. Require concrete code, product, or maintainer
evidence before declining one. Instruct the reviewer to make no edits and
prioritize bugs, regressions, invariant violations, missing tests, scope drift,
and misleading documentation.

Fix valid findings, rerun the proportionate tests, and repeat independent
review until clean. Record justified refusals in the plan's review decisions.
Escalate a repeated ownership-boundary problem after three rounds.

Once clean, hand off:

- The outcome and important design decisions.
- Exact files changed.
- Exact tests and lint commands run with results.
- Remaining risks or follow-ups.
- A Conventional Commit message with the correct issue footer.

The maintainer reviews the final diff and performs staging and committing.
Wait for confirmation that the commit is complete before advancing the queue.

## Maintain Durable State

Use the parent issue's actual sub-issue order as the only cross-chat queue.
Keep parent comments limited to durable decisions, blockers, reorder reasons,
and completion summaries; do not paste transient investigation logs.

Close a child only after its completion criteria are met and the user has
authorized the GitHub update. Closed children remain in the parent as progress
history. Add newly discovered work as a separate child only with explicit
scope authorization, and place it intentionally in the queue.

At a clean issue boundary, decide whether the accumulated chat context merits
compaction. Recommend `/compact` when the current conversation remains useful
and `/new` when a clean issue context would be safer. Never switch or compact
during planning, implementation, review, or while changes are uncommitted.
After `/new`, resume by naming this skill and the parent issue; GitHub, the
issue plan, and Git carry the durable state.
