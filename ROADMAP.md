# Dunia Roadmap

## Current state

Dunia is newly admitted as the OpenStreetMap editor application/integration
repository.

The first milestone is consumer validation rather than GUI construction.

## M0 — Repository admission

Goals:

- establish the application boundary;
- adopt the workspace engineering contract;
- keep reusable library responsibilities outside Dunia;
- establish the normal branch workflow.

Status: **complete**.

## M1 — First real theme/style consumer

Validate one editor selection/accent semantic family against the public
`color-d` API.

Required evidence:

- light, dark and high-contrast built-in variants;
- normal, hover, pressed and disabled states;
- OKLCH derivation and explicit Ray Trace gamut mapping;
- encoded-sRGB output tokens;
- WCAG contrast and perceptual-separation validation;
- CTFE construction for built-in themes;
- the same construction function at runtime for a user accent;
- at least one rejected insufficient-contrast fixture;
- at least one out-of-gamut seed that is explicitly mapped;
- runtime selection among precomputed candidates for different backgrounds;
- DMD and LDC consumer builds;
- compile-time/runtime agreement within underlying numerical contracts;
- API-friction findings recorded back to `color-d`.

This milestone does not select a GUI toolkit or renderer.

Status: **complete**.

Evidence: `docs/research/color-d-theme-consumer.md`.
