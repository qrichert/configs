---
name: mockup-integration
description: Use when integrating a design mockup (HTML/CSS from Claude Design or another tool, a Figma frame, or a screenshot) into a codebase with a component library. Decides per element whether to reuse a component as-is, customize it locally, add a variant, or build a new one, so the mockup is neither pasted wholesale nor flattened into existing patterns.
---

# Mockup integration

A mockup is a spec, not source code. Even when it ships as HTML, it
was generated against an approximation of the design system, so it
mixes deliberate decisions with noise. Keep the decisions, drop the
noise:

- Over-copying pastes the noise: raw values, hand-rolled controls,
  duplicates of library components.
- Under-copying drops the decisions: the result looks like an existing
  page with new data poured in.

Done means: the screen keeps the mockup's intent, is built from the
library, and differs from the mockup only where the difference was a
choice.

## Step 1: Inventory

- Source: if the mockup comes from Claude Design, read the design
  under `project/` with the Artifact tool. If no artifact link
  (`claude.ai/artifact/…`) was given, ask for one. Without the
  Artifact tool, ask for an export of the design's files instead; a
  screenshot loses the structure. Claude Design's bundled design
  system may lag the codebase, so a control the mockup hand-rolls may
  exist in the code: inventory the code, not the bundle.
- The rendered mockup, not just its source: markup alone doesn't show
  what the screen emphasizes.
- Library, both layers: primitives (e.g., `components/ui/`) and app
  components (the rest of `components/`, domain folders included).
  Read each candidate's props, variants, and tests, and the comment
  above its export. Many components own a concern (e.g., how every
  amount is displayed); bypassing an owner is a bug.
- The upstream registry (e.g., shadcn) for components not installed
  yet.
- The scale: the project's tokens for type, spacing, radius, and
  color.
- The project's agent instructions, for who owns vendored components.

## Step 2: Sort the mockup

Every piece of the mockup falls into one of three buckets:

- **Keep: intent.** What is shown, its order and grouping, the
  hierarchy (what is emphasized relative to what), the copy, the
  states, the alignment of figures, the responsive behavior. These are
  why the mockup exists; losing them is under-copying. Keep what it
  shows, not what it implies: its numbers and buttons are
  placeholders. What a figure means and what an action does come from
  the app's existing behavior, or are a decision to flag in the table;
  never invent them.
- **Translate: values.** Font sizes, spacing, radius, colors. Never
  copy them; map each to the project's scale by role (caption, label,
  body, figure, heading). Generated mockups use a continuum, not a
  scale (one used 13 font sizes, `11.5px` most of all). Snap to the
  step that serves the same role. A raw value only matters if it
  separates two roles the scale would merge; then it is a missing
  token: flag it, don't inline it.
- **Replace: implementation.** Anything the library already has (a
  button, a field, a card, a formatted amount) becomes the component.
  The mockup's markup for it is discarded.

## Step 3: Decide each replaced element

First, is it the same thing as an existing component: same role,
behavior, data shape, and accessibility semantics? If not, and no
combination of components covers it, it is a **new component**. Build
it from library parts; make it shared if it names a reusable concept,
otherwise keep it in the feature.

If it is the same thing, decide what to do with the remaining
difference:

1. **Reuse as-is.** The difference is noise or cosmetic. Accept not
   matching the mockup. This is the default.
2. **Reuse, customized locally.** The difference matters but belongs
   to this placement: layout (width, alignment, margin, grid area,
   truncation) or a one-off emphasis in context. Only through the
   component's public surface (`className` on its root, its props).
   Never restyle its look (color, radius, padding, font) wholesale,
   unless the component documents that override as the caller's
   (e.g., an amount's sign colors). Never reach into its internals.
3. **Reuse with a new variant.** The difference matters and belongs to
   the component: you can name it without naming this screen
   ("compact", "subtle", "emphasized"), or the same appearance
   customization shows up a second time. Placement classes (`w-full`,
   margins) stay local however often they repeat. Add a variant or
   prop. For a vendored primitive under ownership rules, flag it
   instead of editing.

If matching the mockup would mean overriding a component's internals,
it is not a local customization: it is a variant, a new component, or
a difference to accept.

Tie-breakers:

- Would a user notice the difference, and would it change what they
  understand or do? No: reuse as-is.
- Does it change how the component looks or where it sits? Where it
  sits, or a look the component documents as the caller's: local. How
  it looks otherwise: variant, or accept it.
- Can you name it without naming this screen? Yes: variant. No:
  local, or accept it.
- Still unsure: reuse as-is and flag it in the table.

## Step 4: Mapping table, then STOP

| Element | Intent kept | Outcome | Component / path | Delta | Reason |
| ------- | ----------- | ------- | ---------------- | ----- | ------ |

`Delta` records what was translated or accepted. `Reason` says where
each choice comes from: the mockup, the app's existing behavior, or a
proposal. Include the states the mockup doesn't show (empty, loading,
error), with their existing behavior or a proposal.

Present the table and wait for approval of the table itself: a
request to implement the mockup is not approval of it. If running
unattended, reuse as-is for every ambiguous presentation choice and
list them at the top of the final report; leave anything that needs a
product decision pending.

## Step 5: Implement, verify, and report

Implement the approved table. Mockup text goes through the project's
i18n, if it has one, and figures through their owning component.

Then compare the rendered result with the mockup at the same viewport
sizes and states: hierarchy, density, grouping, figure alignment,
overflow. Where the mockup shows no responsive behavior, check the
agreed behavior instead of claiming a match. If you can't render the
result or the mockup, say which areas are unverified: reading the
source doesn't establish visual fidelity.

End with:

- The final table.
- Accepted deltas, and why each is fine.
- Library gaps worth promoting: variants, new components, missing
  tokens.
- What was compared, what still differs, and what wasn't verified.

## Red flags

Over-copying (stop and re-sort):

- Raw mockup values in the code (`text-[11.5px]`, inline px, hex).
- Mockup markup for something the library has (a styled `<button>`, a
  hand-formatted amount).
- A local customization that restyles a component's look beyond what
  it documents as the caller's, or the same appearance customization
  twice.
- A new component named after the mockup (`MockupHeader`, `FooCard2`)
  or justified by "to match the mockup".

Under-copying (stop and re-read the mockup):

- The screen reads like an existing page with the mockup's data poured
  in.
- Hierarchy, grouping, or order the mockup decided is gone.
- Copy rewritten, states dropped, figure alignment lost.
- Reuse as-is chosen for a difference that recurs across the mockup,
  where a variant was due.
