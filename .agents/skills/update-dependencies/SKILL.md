---
name: update-dependencies
description: Upgrade project dependencies and coordinated runtime pins across Bun, uv, Cargo, CI, and containers; update manifests and lockfiles and validate with the pinned runtimes. Use for full project dependency refreshes, not a request to add or update one named package.
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
3. Check current runtime releases and compatibility with proposed
   dependency upgrades using upstream release notes and supported
   version ranges. Look for a supported runtime fix before downgrading
   a dependency or adding a test-environment workaround. Keep
   development, test, CI, and production declarations aligned, or
   explain intentional differences.
4. Aim for the latest available direct and transitive versions,
   including breaking major releases. Audit pins, upper bounds,
   overrides, and patched packages for staleness. Do not preserve them
   merely because they were previously necessary. Verify whether
   upstream absorbed a patch before removing it.
5. If current releases conflict, establish the project's dependency
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
  `patchedDependencies`. Inspect each patch file against the upgraded
  package to decide whether its fix is still needed and whether the
  patch still applies. Remove obsolete patches; revise and re-create
  patches that need updating with `bun patch`. Verify that a frozen
  install applies every retained patch and run targeted tests for its
  intended behavior. Keep the manifest, lockfile, and patch files
  aligned through Bun's workflow.
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

Run targeted tests for incompatibilities and fixes first, then the
affected unit and integration suites. Verify the installed runtime
version and run these checks with the version CI actually installs,
rather than assuming the local version matches. Build every affected
project with its repository wrappers, including production builds. When
runtime changes affect a container image, build and smoke-test that
image if the environment supports it. Run relevant lint, type, schema,
and lock-consistency checks. For browser suites, run selected E2E cases
rather than the full suite unless the user asks for it. Fix only
regressions caused by the upgrade and rerun affected checks. Neither
passing lints nor a passing build substitutes for tests.

Review the final diff for unrelated edits and unresolved constraints.
Search the whole repository for superseded runtime and package-manager
versions, and verify that CI setup, manifests, version files, and container
images agree on the intended versions.
Report exact files and versions changed, builds and tests run, any
packages left below latest with evidence, and validation that could not
run.
