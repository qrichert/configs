---
name: update-dependencies
description: Upgrade all dependencies in a project to the latest available versions, including major releases, across Bun, uv, and Cargo; update manifests and lockfiles and validate the result. Use for full project dependency refreshes, not a request to add or update one named package.
---

# Update dependencies

Upgrade every dependency ecosystem present in the requested scope. Follow
the repository's instructions, approval rules, package manager, and build
and test wrappers. A user-requested narrower scope takes precedence.

## Discover and decide

1. Inventory manifests, lockfiles, workspaces, update recipes, version
   constraints, overrides, patches, and existing work. Determine which
   packages and projects the request covers before changing them.
2. Inventory runtime and package-manager pins across the whole repository,
   including CI workflows, container base images, manifest
   `packageManager` fields, and tool version files. Search for every current
   version before editing, then update the coordinated pin set together or
   explicitly report why a reference is outside scope.
3. Aim for the latest available direct and transitive versions, including
   breaking major releases. Audit pins, upper bounds, overrides, and
   patched packages for staleness; do not preserve them merely because
   they were previously necessary. Verify whether upstream absorbed a
   patch before removing it.
4. If current releases conflict, establish the project's dependency
   priority and test the conflict. Prefer its primary product dependency
   over adapters, and adapters over their transitive libraries (for
   example, Django over Django Ninja over Pydantic). Keep an older
   version only for a demonstrated incompatibility, and report the
   evidence and affected functionality. Ask when that priority is
   genuinely ambiguous or the required fix exceeds the approved scope.

## Upgrade with the package manager

- **Bun:** In each Bun project, run `just update-aggressive` when that
  recipe exists; otherwise run `bun update --latest --force`. Review
  changes to `package.json` and `bun.lock`, especially `overrides` and
  `patchedDependencies`. Update or remove those through the package
  manager's supported workflow when evidence shows they are stale.
- **uv projects:** Check the current status and supported uv commands
  for [#1419](https://github.com/astral-sh/uv/issues/1419) and
  [#6794](https://github.com/astral-sh/uv/issues/6794) before choosing
  the workflow. #1419 concerns plain virtual environments; #6794
  concerns upgrading project manifest requirements. Use a native
  manifest-upgrade command if one is available. Otherwise run
  `uv lock --upgrade` and `uv sync`, then update stale direct
  requirements in `pyproject.toml` with `uv add` using explicit version
  requirements. Preserve relevant extras, markers, and dependency
  groups. An existing lower bound is not necessarily raised by
  `uv add --upgrade` or `uv add --bounds lower`; specify the resolved
  version when updating it. Rerun `uv lock --upgrade` and `uv sync` so
  the manifest, lockfile, and environment agree. Use uv rather than
  editing dependencies by hand.
- **Cargo:** Run `cargo upgrade -i` to allow incompatible major
  requirements, then refresh `Cargo.lock` with `cargo update`. Inspect
  workspace manifests and features for unchanged or newly incompatible
  requirements. If an exact pin still blocks a justified upgrade, use
  Cargo's `--pinned allow` option after checking why the pin exists. Use
  Cargo tools for dependency changes.

If the repository supports another package manager, use its supported
full-latest workflow with the same manifest and lockfile checks.

## Validate and report

Run targeted tests for incompatibilities and fixes first. Then build and
test every affected project with its repository wrappers. Run relevant
lint, type, schema, and lock-consistency checks. For browser suites,
run selected E2E cases rather than the full suite unless the user asks
for it. Fix only regressions caused by the upgrade and rerun affected
checks. Do not treat a passing build as a substitute for tests.

Review the final diff for unrelated edits and unresolved constraints.
Search the whole repository for superseded runtime and package-manager
versions, and verify that CI setup, manifests, version files, and container
images agree on the intended versions.
Report exact files changed, builds and tests run, any packages left
below latest with evidence, and validation that could not run.
