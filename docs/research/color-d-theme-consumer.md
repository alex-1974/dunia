# color-d theme consumer validation

Status: **validation in progress**

This document records Dunia's first real consumer validation of `color-d`.

## Consumer slice

The application owns one selection/accent semantic family:

```text
semantic OKLCH seed
    -> Dunia lightness/chroma schedules
    -> color-d tone construction
    -> explicit Ray Trace gamut mapping
    -> prepared linear + encoded sRGB values
    -> Dunia contrast / state-separation policy
```

Fixed built-in Light, Dark and High Contrast themes are generated at CTFE by
the same `makeSelectionTheme` function used at runtime for a user accent.

Runtime map-background adaptation does not regenerate colors. Dunia chooses
among a small CTFE-prepared candidate set using WCAG contrast as the primary
measurement and `deltaEOK` as a near-tie discriminator.

## Boundary

Dunia owns:

- semantic role names;
- interaction states;
- lightness/chroma schedules;
- contrast thresholds;
- perceptual-separation thresholds;
- candidate-selection policy;
- map-background interpretation.

color-d owns only the reusable color mathematics.

No OSM tag, renderer, GUI toolkit or application semantic type is added to
color-d.

## Validation cases

The consumer code mechanically covers:

- Light / Dark / High Contrast built-ins;
- normal / hover / pressed / disabled states;
- CTFE construction and compile-time validation;
- runtime construction using the same function;
- CTFE/runtime encoded-token agreement under a consumer tolerance;
- an insufficient-contrast fixture rejected by Dunia policy;
- a vivid out-of-gamut OKLCH seed that is explicitly Ray-Trace mapped;
- valid final sRGB candidates;
- dark and light map-background samples selecting different candidates;
- DMD 2.113.0 and LDC 1.43.0 builds.

## Initial hosted-runner characterization

On the first successful focused run before the runtime benchmark was added:

| build | elapsed | max RSS |
| --- | ---: | ---: |
| DMD 2.113 debug | 0.48 s | 130944 KiB |
| LDC 1.43 release | 2.57 s | 262160 KiB |

Prepared static theme data reported by the consumer is 648 bytes for three
built-in `SelectionTheme` values plus one `SelectionCandidates` value.

Example runtime selections from that run:

```text
dark background  contrast=18.4245 deltaEOK=0.8238 rgb=(0.9577, 0.9760, 1.0000)
light background contrast=18.5527 deltaEOK=0.8808 rgb=(0.0013, 0.0067, 0.0208)
```

These hosted-runner values are characterization evidence, not performance
guarantees.

## API friction

No actionable color-d API friction has been found so far.

The consumer uses the root import surface and ordinary value operations. No
theme builder, palette wrapper, OSM role, renderer hook, allocation API or
application-specific convenience function is required from color-d.

Final status and runtime construction cost will be recorded after the refreshed
DMD/LDC PR checks complete.
