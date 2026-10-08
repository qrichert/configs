---
name: hoplageiss-alignment
description: Plan, port, or audit shared Hoplageiss changes in Skoscht when explicitly invoked; preserve byte-level template parity and commit provenance.
---

# Hoplageiss Alignment

Use this skill only for a Skoscht–Hoplageiss alignment request. Read the
current Skoscht `AGENTS.md` before work. The latest synchronized commit
recorded there and the repositories' current state are inputs, not
assumptions to carry over from another session.

This skill is the complete template-sync protocol. Skoscht's
`AGENTS.md` names it for template ports and still applies. The agent may
inspect Git but must never stage, unstage, commit, or push. The
maintainer owns those operations. Never read or expose secrets.


# Template Sync Protocol

Skoscht periodically ports shared application infrastructure from
Hoplageiss. A port is a subtractive copy operation, not a rewrite: copy
the upstream source first, remove omitted product behavior, and adapt
only the smallest spans required by an approved Skoscht difference.

Behavioral equivalence, visual equivalence, and passing tests do not
prove template parity. File inventory, byte checks, content diffs, and
test correspondence are separate acceptance requirements.

## Byte Fidelity

Porting shared source is verbatim. Identity means the same bytes, not
similar behavior, formatting, meaning, or rendered output. This includes
code order, comments, docstrings, punctuation, capitalization, wrapping,
and tests. Copy the upstream file or retained region first and confirm
its identity before any required Skoscht adaptation.

For complete files, use exact byte comparison and matching hashes (for
example, `cmp` and `sha256sum`) in addition to the parity inventory. For
partially retained files, compare the copied regions byte-for-byte with
an exact tool before editing them. Then use a real content diff for
every remaining mismatch and explain each changed span. A whole-file
hash mismatch is expected after an approved partial omission or
adaptation; it never excuses drift in retained shared regions. Do not
infer byte identity from semantic or visual tests.

Adapt only product/domain behavior, deliberately omitted features, the
selected dependency or component-library variant, or visual design when
required by Skoscht. User-approved deviations also qualify. Convenience,
preferred naming, smaller diffs, and improvements are not reasons to
change shared bytes. Change the smallest span and preserve the rest. If
a comment mixes shared and project-specific facts, edit only the false
clause and keep its wrapping unless the edit requires rewrapping.

## Durable Divergence Boundaries

These are semantic boundaries, not path-wide exemptions. A file that
contains an accepted difference can also contain unrelated drift, so
every changed hunk still requires review.

- Skoscht product identity, finance domain behavior, metadata, fixtures,
  onboarding, and branding differ from Hoplageiss where their meanings
  differ.
- Oomph is deliberately omitted.
- Skoscht does not use account quotas.
- Hoplageiss's dedicated-server `.ansible/` tree and infrastructure
  document are deliberately omitted while Skoscht runs on a server
  shared with other applications. Reassess that boundary if Skoscht
  moves to a dedicated server.
- Hoplageiss's mixed-domain `async.md`, `configuration.md`,
  `management-commands.md`, and `user-privileges.md` documents are
  deliberately omitted for now. Reassess them when expanding Skoscht's
  developer documentation.
- Hoplageiss public-profile-only behavior is omitted. French copy may
  say `profil` instead of `profil public` where the profile is not
  public, but generic authentication copy and placeholders remain
  shared.
- Skoscht headings are not extra-bold.
- Skoscht's header command palette uses one icon-only trigger. The
  global Command-K keyboard shortcut remains available.
- Skoscht's header settings button retains Base Luma's default icon
  button size instead of Hoplageiss's responsive consumer sizing.
- Skoscht's visitor landing logo remains owned by `(main)/layout.tsx`,
  and its authenticated overview breadcrumb remains owned by
  `AppHeader`. Do not copy Hoplageiss's route-aware `HeaderLogo` or
  `Breadcrumbs` components merely to recreate those behaviors. Port
  their regression coverage to the local owners instead.
- Hoplageiss's dynamic leading-breadcrumb overflow fix is intentionally
  omitted while Skoscht's leading overview breadcrumb is a bounded
  prototype label. Reassess this when `AppHeader` becomes route-driven.
- Hoplageiss's Markdown editor and `/markdown` documentation route
  belong to an omitted content-authoring feature. Shared documentation
  entry points remain required.
- The canonical local `base-luma` shadcn variant owns primitive APIs,
  DOM composition, and class strings. Hoplageiss contributes shared
  behavior, features, tests, load-bearing comments, and consumer
  composition. Never copy Hoplageiss's `base-vega` class strings over
  the local variant.
- A suspected defect in shared Hoplageiss code is not an accepted local
  divergence. Preserve parity and report the defect upstream.

Anything outside these boundaries is either a clear miss or requires an
explicit user decision. Convenience, cleanup, preferred naming, and a
locally "better" implementation are not accepted boundaries.

## Freeze the Inputs

Record three immutable inputs before editing:

1. The Skoscht starting commit.
2. The Hoplageiss commit recorded as the latest synchronized target.
3. The new Hoplageiss target commit.

Do not use branch names as final audit evidence. Resolve and report the
full commit IDs so a moving branch cannot change the comparison during
the port.

## Inventory Before Editing

From the Skoscht repository root, generate the full inventory and
upstream delta:

```console
just template-parity-delta PREVIOUS_TARGET NEW_TARGET \
  > ~/.codex/plans/skoscht-template-sync-audit.md
```

The command compares the Skoscht working tree by default. Pass an
immutable Skoscht commit as the third argument when reviewing a fixed
snapshot:

```console
just template-parity-delta PREVIOUS_TARGET NEW_TARGET SKOSCHT_COMMIT \
  > ~/.codex/plans/skoscht-template-sync-audit.md
```

The report includes:

- Every byte-identical and content-different same-path file.
- Every mode difference.
- Every Skoscht-only and Hoplageiss-only path.
- Every target-only test-area path, including support files and
  fixtures.
- Every path added, copied, deleted, modified, or renamed between the
  two Hoplageiss targets.
- The same Hoplageiss changes grouped by first-parent commit so the port
  does not flatten upstream provenance.

Working-tree mode includes tracked and non-ignored untracked files. It
does not read paths that may contain credentials; those appear as
unverified and must remain unresolved rather than being opened by an
agent.

The inventory is deliberately policy-free. It prevents skipped paths but
does not decide whether a difference is justified.

## Classify Before Editing

Inspect every path in the Hoplageiss delta and every affected existing
Skoscht difference. For every source file, explicitly locate its target
tests; for every target test, locate its source module and Skoscht
counterpart. Same-path matching alone is insufficient because modules
and tests may have been moved, split, flattened, or combined.

Assign one classification before changing code:

- **Exact copy:** The complete file or retained region must match the
  target byte-for-byte.
- **Necessary adaptation:** Identify the exact span and the durable
  divergence boundary that requires it.
- **Intentional omission:** Identify the omitted product feature that
  owns the file or region.
- **Unsure:** Stop and obtain a user decision. Do not convert
  uncertainty into a local design choice.

Use a diff tool for every content-different path. Read the entire diff,
not only function names or visually prominent hunks. Review ordering,
comments, docstrings, wrapping, imports and exports, wrapper functions,
JSX ownership, and asynchronous call boundaries.

For shadcn components, perform a three-way comparison with Hoplageiss
and the canonical local Base Luma registry source. Do not infer
ownership from which version looks preferable.

For Django schema changes, generate Skoscht migrations with Django
against Skoscht's own migration graph. Do not copy an upstream migration
merely to satisfy byte parity when its number, dependencies, or schema
history differ. Compare the generated operations with upstream and
explain necessary differences. Never hand-edit a generated migration
without the maintainer's explicit approval.

## Commit Disposition and Provenance

Inspect every upstream commit, including commits that concern features
Skoscht omits. Classify each as a full port, partial port, no port, or
principle-only port. A correction to an omitted feature can still expose
a soundness principle that applies to another Skoscht feature; inspect
that possibility before choosing no port. Record the reasoning in the
porting review. A no-port commit that warrants no Skoscht change is a
no-op: move to the next upstream commit without a Skoscht commit or an
`AGENTS.md` edit.

Preserve upstream commit granularity for Skoscht changes. For each
resulting Skoscht alignment commit, hand the maintainer a proposed
full commit message (subject, body, and applicable footers) that follows
the upstream message as closely as the actual port allows. If upstream
has a body, the proposed message must have a body; never hand over only
its subject. Copy shared wording verbatim, adapting only inaccurate
product-specific claims and omitting irrelevant issue references.
Explain material scope differences when needed. Include in that same
proposed commit an update to
`AGENTS.md`'s latest synchronized Hoplageiss ref, using the full commit
ID of the upstream state represented by the port. Do not create a
separate bookkeeping commit. Keep the date on that `AGENTS.md` line
accurate for the recorded ref. The maintainer performs all Git
mutations.

A strict follow-up repair of its originating commit, such as a typo or
small bug fix that should have been in that commit, may be folded into
the original port and skipped when the fix commit is reached. Record the
folded mapping and compare the resulting shared bytes to the corrected
upstream state. The port's recorded ref must represent that corrected
state. A broader architecture correction normally stays a separate
commit. Use judgment to keep this exception narrow.

Preserve a defect or typo found in shared upstream code rather than
silently fixing it only in Skoscht. Collect such findings for an issue
in Hoplageiss, preferably one issue for the porting pass, using its
issue template. When Skoscht already has a better implementation of an
upstream fix, classify that code change as no-port and raise the
alignment opportunity upstream. Prepare the concrete issue before
posting; create it when the user's authorization covers that external
write, otherwise hand it to the maintainer ready to post.

## Plan and Approval

For a straightforward port, give the maintainer a concise in-chat
disposition before editing: what changes, what is intentionally omitted,
and what requires Skoscht adaptation. Keep the required inventory and
parity evidence in durable audit reports; the maintainer does not need
to review a long implementation plan for mechanical copy or rename
commits. Pause after the disposition and ask the maintainer to validate
the intended changes, omissions, and adaptations before implementing.
An existing request to carry out the alignment does not replace this
checkpoint; skipping a formal plan does not authorize implementation.

For a genuinely non-trivial port, investigate the relevant code and
write the canonical implementation plan to
`~/.codex/plans/<descriptive-name>.md`. This applies when semantics,
ownership, API shape, migration strategy, or an uncertain divergence
boundary needs a maintainer decision. Define the goal, locked scope and
semantics, commit disposition, concrete changes by file and symbol,
tests and validation, risks, and non-goals. Present that plan for review
and wait for explicit validation of the intended port and implementation
approval. A request to inspect or review the plan does not authorize
implementation. If an internal API conflict requires a workaround, stop
and propose the smallest normalizing refactor first.

## Implement Copy-First

Apply each classified port in upstream commit order. For each port:

1. Copy target files or shared regions verbatim.
2. Confirm the copied bytes before adaptation.
3. Delete deliberately omitted behavior.
4. Apply only the classified minimal adaptations.
5. Port the corresponding tests with the same fidelity.
6. Prepare the `AGENTS.md` ref update for the same Skoscht commit.

Adapt shared test assertions only where an approved semantic or visual
difference makes the original assertion false. For shadcn components,
compare the result against both Hoplageiss and the canonical local
registry variant; report exact copies and necessary adaptations.

Do not reconstruct upstream code from memory. Do not refactor shared
source while porting it. If the target architecture conflicts with an
existing Skoscht API, stop and propose the smallest normalizing change
before adding a workaround.

Run formatters only after the copy and adaptations are explicit. A
formatter change is still a content difference and must remain visible
in the final diff.

## Audit After Implementation

Generate a new whole-tree report:

```console
just template-parity NEW_TARGET \
  > ~/.codex/plans/skoscht-template-sync-final-audit.md
```

Re-diff every content mismatch. Reclassify every one-sided path and
repeat the target-only test review. Do not limit the second inventory to
files changed during the port: a new upstream file can reveal an older
missing counterpart, and edits can disturb shared surroundings.

The completion report must state:

- The disposition of every upstream commit, including principle-only
  ports, no-ops, and any folded strict fixes.
- Both exact target commits.
- Source, target, shared, byte-identical, content-different,
  mode-different, source-only, target-only, and target-only-test-area
  counts.
- Every exact copy introduced by the port.
- Every remaining adaptation and its precise reason.
- Every intentional omission and its owning product boundary.
- Every test and validation command run.
- Every unresolved or unverified path.

Passing tests cannot replace this evidence. Likewise, the generated
report cannot replace project tests.

For a non-trivial port, commission a fresh-context, read-only audit.
Give the reviewer this protocol, the frozen refs, and the durable
divergence boundaries, but not the implementer's findings or conclusion.
The reviewer must independently enumerate the union, checksum shared
files, inspect all diffs, and verify test correspondence.

## Rewriting Port History

History rewriting does not invalidate an audit if the resulting Git tree
is byte-identical to the audited snapshot. Compare the final tree
against the audited commit after the rewrite. If conflict resolution or
later edits change any path, audit those differences and regenerate the
whole-tree inventory before updating the recorded Hoplageiss target.
