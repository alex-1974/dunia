# AGENTS.md

Dunia is the OpenStreetMap editor application/integration layer of the
d-geospatial-workspace.

Before making architectural, API, implementation, testing, CI,
repository-structure, release, numerical, performance, or toolchain decisions:

1. Read the canonical workspace engineering documents exposed under
   `.workspace/`.
2. Treat those workspace documents as the current shared engineering contract.
3. Preserve Dunia-specific application boundaries documented in this repository.
4. Do not move reusable library responsibilities into the application merely for
   convenience.
5. Add workspace dependencies only when required by a concrete implementation
   slice.
6. Preserve active pre-migration work according to
   `.workspace/GIT_GITHUB_WORKFLOW.md`.
7. When workspace rules and repository state appear inconsistent, inspect the
   repository first and document the discrepancy before changing anything.

Dunia owns editor/application policy and cross-library integration. Reusable
geometry, OSM data, color mathematics, raster/image mechanics, and similar
library domains remain in their respective reusable packages.
