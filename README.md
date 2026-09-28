# Dunia

Dunia is the working-title OpenStreetMap editor application for D.

The repository is the application and integration layer of the
`d-geospatial-workspace`. Reusable domain functionality remains in independent
libraries; Dunia owns editor policy, interaction, GUI/renderer integration and
cross-library orchestration.

## Current status

The application is at its first consumer-validation slice.

The initial technical goal is deliberately narrow: validate `color-d` from a
real editor theme/style consumer before either the Dunia theme model or
`color-d` v0.1 is frozen.

No GUI toolkit, renderer architecture, OSM editing model, plugin system or
configuration format is selected by the initial scaffold.

## Dependency policy

Dependencies are admitted only when required by a concrete implementation
slice. The first slice uses `color-d` only.

## Workspace

When checked out inside `d-geospatial-workspace`, canonical shared engineering
documents are exposed through the ignored `.workspace/` directory. See
`AGENTS.md`.
