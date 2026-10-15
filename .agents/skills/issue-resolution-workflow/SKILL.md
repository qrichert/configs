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

## Scope and Proportionality

Apply the applicable `AGENTS.md` simplicity and extraction rules when planning
and reviewing, including rules specific to frontend components. Keep plans,
delegation, implementation, and tests proportionate to the requested outcome.
Workflow completion and passing checks do not establish proportionality.

Distinguish the minimum requested invariant from existing guarantees and any
stronger guarantee the proposed fix introduces. A stronger guarantee beyond the
requested outcome needs a concrete justification, including its UX cost and
failure behavior. Do not turn an advisory observation into a blocking policy
without establishing that the requested behavior requires it.

Questions about the work or this workflow call for a direct answer. Discussion
alone does not restart planning or authorize implementation changes.

## High-Level Summary (Always Required)

Always include a concise, self-contained high-level summary in chat when
presenting a proposed resolution, requesting approval, or handing off the
result. This applies in Plan mode and when a full written plan is omitted.
Explain the problem, what will change and why, the resulting behavior,
and any material decision or tradeoff the maintainer needs to assess.

A plan file, its path, or a task checklist never replaces this summary.
When the proposal changes, summarize what changed and why. The full plan
may be optional under the rules below; the summary is never optional.

## Model Selection and Delegation

When model selection and delegation are available, prefer a stronger
model for investigation synthesis, planning, and independent plan and
diff reviews. Use a smaller capable model for bounded investigation and
mechanical implementation of an explicitly approved plan, including its
focused tests. Give the implementer the approved proposal, any canonical
plan, applicable instructions, and locked scope; return new architectural
or product decisions to the planning model. The implementer must not serve as its
own independent reviewer. Choose models by task difficulty and available
capabilities rather than hard-coded model names.

Invoking this workflow authorizes delegation without asking first. Use the
roles above where independent judgment or parallel work materially helps;
agent count and separate assignments should follow the task's complexity.

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

For non-trivial work, write a canonical plan named
`issue-<id>-<descriptive-slug>.md` in the agent's default plan directory
if it has one (e.g., `~/.claude/plans/`), or in `~/.<agent>/plans/`
otherwise (e.g., `~/.codex/plans/`). For a tracker without a numeric ID,
use its stable issue key. Include:

- Goal, acceptance criteria, and the evidence from the issue and current code.
- Locked scope, intended behavior, invariant owner, and meaningful tradeoffs.
- Concrete changes by file and symbol, including migration, concurrency,
  compatibility, and failure semantics where relevant.
- Focused tests, affected compatibility checks, lint or other validation,
  risks, and explicit non-goals.
- Review decisions and concrete reasons for declining actionable findings.

For a narrow mechanical change with no product or architecture decision,
the in-chat proposal can suffice unless applicable instructions or the
maintainer require a full written plan. Keep scope and review decisions
in chat in that case. The summary and implementation approval remain
required either way.

Keep the plan focused on affected behavior and decisions; cover migration,
concurrency, and compatibility only where relevant. Explain why the proposed
behavior is necessary before detailing its mechanisms or state combinations.

Make ordinary implementation choices in the plan. Ask for an earlier product or
architecture decision only when it cannot be inferred safely. For a substantive
plan, use an independent reviewer when delegation is available.
Have the reviewer read the issue, applicable instructions, and current code
before the plan, then assess correctness, scope, design, UX cost, simplicity,
and relevant migration and validation concerns. Challenge the necessity of the
chosen guarantees as well as their implementation. Resolve actionable
findings and update the plan. Do not treat the plan's stated intent as
evidence that a potential regression is acceptable.

Present the required high-level summary, link any written plan, and wait
for explicit approval before implementing. A question, correction, or
objection is not implementation approval. Update the canonical plan,
when present, when an approved decision changes.

## Triage Review Findings

Apply this to every review, of the plan or of the diff, before changing
anything. A finding is a claim to weigh, not an instruction.

Classify each finding and write its class in the response:

- **New:** the decision it touches was never considered. Assess it on
  its merits.
- **Already decided:** it contradicts a decision recorded in the plan or
  its review log. Name that decision, then state what is new: a
  scenario, impact, or fact the decision did not consider. Restating the
  risk more forcefully, or reproducing a case the decision already
  accepted, is not new. With nothing new, decline and cite the recorded
  reasoning.
- **Contradicts the maintainer:** escalate it to the maintainer; never
  silently accept or reject it.

Conceding is never the default. If the "what is new" line cannot be
filled in, the finding is declined. Record every decline and its reason
in the plan's review log, or in chat when no written plan is needed.

## Implement and Validate

Follow the approved plan within its locked scope. Preserve unrelated work.
Never stage, unstage, commit, push, revert, or discard the maintainer's work.
If the code reveals a conflicting internal API, wrong ownership boundary,
unexpected scope expansion, or a new product decision, stop the affected work,
explain the finding, and revise the plan or seek a decision before proceeding.
Reassess whether implementation remains warranted when new evidence appears.

For a bug, add a focused regression test first when practical and useful. Each
added test should protect a distinct behavior affected by the change, including
preserving valid cases. Avoid duplicate execution paths and permutations that
add no distinct coverage. Tests of unchanged framework guarantees need a
concrete change-specific risk. Factor genuinely repeated test setup or waits
according to the project's conventions, without building a generic harness.

Run validation proportionate to the change: narrow tests, compatibility checks
implied by the diff, then affected lint or type checks. Report exact commands
and results. Broaden testing only for a concrete remaining risk or required
gate.

## Review and Hand Off

Review the uncommitted diff against the issue, current code, and approved plan.
For a substantive change, use an independent reviewer when delegation is
available. Have that reviewer inspect the issue discussion,
applicable instructions, diff, and surrounding code before reading the plan.
Prioritize bugs, regressions, invariant violations, missing tests, scope drift,
unnecessary complexity, and misleading documentation. Check the actual diff
for unnecessary gates and states, duplicated UI, repeated test scaffolding,
and tests that do not distinguish the fix from broken behavior. A large diff
prompts this check; reducing line count alone is not the objective. Reviewers
must challenge the requested necessity and UX cost of behavior even when the
implementation matches the plan. Apply finding triage before adding more
mechanisms or tests in response to a review.

After fixing a finding, review that fix narrowly and rerun relevant
validation. Repeat this focused loop for any new findings.
Then review the complete final changeset against its base, including all earlier
commits and review fixes. If the full review finds an actionable issue, fix it,
review the fix narrowly, and repeat the full review. Hand off only after a full
review has no actionable findings. Record concrete reasons for declined findings
in the plan, or in chat when no written plan is needed. A plan cannot by
itself justify a user-visible failure or weakened invariant.

As the final step before every hand-off, run `just lint` from the
repository root and report its result. It is the only accepted lint gate:
module-level or hand-picked lint commands are partial and never replace it,
since the root recipe also runs cross-cutting checks such as schema parity and
root-file formatting.

Hand off the outcome, important decisions, exact files changed, validation
commands and results, remaining risks, and a suggested commit message. Leave
staging and committing to the maintainer. Close or update the issue only when
its completion criteria are met and the user has authorized that tracker
change.

## Multiple Issues

Apply this entire process to each issue in sequence, with a separate plan and
review for each. Use the user's stated order or the tracker's explicit order;
ask if the order remains ambiguous. Do not start the next issue while the
previous change cannot be isolated safely. Parent issues and sub-issue queues
are optional tracker context, not prerequisites for this workflow.
