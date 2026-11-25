---
name: technical-writing
description: Write, edit, or review documentation to match its existing audience, style, structure, and level of detail. Use for README changes, guides, and other prose in an existing documentation set, including documentation updates made as part of a coding task.
---

# Technical Writing

Make the change read as part of the existing document. Technical
correctness alone does not establish that the writing belongs there.

## Before drafting

- Read the affected section and its surroundings. Find a comparable
  passage in the same document or documentation set when needed.
  Headings and search snippets alone do not establish its style.
- Identify the audience, what they need to do, the document's language
  and voice, and its usual structure and amount of explanation. Use
  these as drafting constraints; keep this analysis out of the user's
  way unless a decision needs discussion.
- Follow the user's requested action. Discussing a problem or reviewing
  prose does not itself authorize editing files or changing persistent
  instructions.

## Draft to fit

- Don't put edge cases into titles, introductions or overviews. Use
  titles, headings, and one-line API summaries to describe the common
  case. Explain the exception in the body if readers need it.
- Before setup instructions, explain the problem the feature solves,
  who benefits, and when to use it. Describe the practical outcome for
  the reader; naming a setting or explaining its mechanics is not
  enough. A sentence alongside a configuration entry may suffice.
- For a setting, make the causal chain explicit: what happens without
  it, what changes when it is set, and why that change is needed. State
  the relevant deployment context instead of assuming the reader knows
  it. Explain trust requirements through the behavior they permit.
- Stop once the reader can decide whether to use the setting and
  configure it correctly. Add detail only when omitting it would change
  that decision or prevent an operator action. Remove unnecessary ideas
  before shortening sentences; compressing an implementation inventory
  does not make it appropriate for operators.
- Use the smallest change that gives the intended reader what they
  need. Match nearby terminology, paragraph length, headings, examples,
  tables, and degree of formality. Explicit user direction takes
  precedence over the existing style.
- Keep the addition proportionate to its operational significance. One
  optional setting may need a table row and a short paragraph; a new
  deployment procedure may need a full section. Do not turn every
  implementation detail into a documentation requirement.
- In an operator README, include what helps installation, setup, use,
  operation, or troubleshooting. Put algorithms, internal invariants,
  and library integration details in the appropriate code docs,
  docstrings, or existing developer documentation when needed within
  the authorized scope. A footnote does not make irrelevant material
  appropriate for the audience.
- Preserve necessary behavior, caveats, and context without repeating
  them in several places. Check whether the right location already
  documents a fact before adding it again.
- Preserve unrelated prose. Condense the material being drafted or
  explicitly selected for revision; do not use style matching as a
  reason to shorten or restructure the rest of the document.

## Check before finishing

Read the revised passage alongside its neighbors and assess:

- **Audience:** Does each addition help this document's reader?
- **Purpose:** Can the reader tell why and when to use the feature, and
  what problem it solves?
- **Style:** Does the language and structure match the surrounding text?
- **Proportion:** Does the space given to the change match its importance?
- **Placement:** Are technical internals in the appropriate code or
  developer documentation?
- **Redundancy:** Is any explanation repeated or unnecessary?

Revise any mismatch before handing off, even when the content is
accurate and lint passes. These checks also apply when reviewing another
author's draft. Report the actual changes and relevant validation
briefly; do not replace a requested fix with apologies or promises.
