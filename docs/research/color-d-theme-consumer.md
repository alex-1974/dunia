# color-d theme consumer validation

Status: **PASS — color-d editor/theme consumer boundary validated**

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

## Validated state

Final focused PR run: `36439746570`.

Validated source state:

- Dunia feature source: `7521639630c3fe432b1c6456f06b99fe5fc50a20`;
- PR merge-test commit: `a787f0fb54261b9251ea3ad7992b6751276305de`;
- color-d: `65aa8fd53d52c2d9436ba1fdf3917ef48efd3f74`;
- DMD: 2.113.0 debug consumer build;
- LDC: 1.43.0 release consumer build;
- runner: GitHub-hosted Ubuntu 24.04 x86-64.

Both the generic Dunia CI and focused theme consumer workflow passed under
DMD and LDC.

## Hosted-runner characterization

Final focused-run build characterization:

| build | elapsed | max RSS |
| --- | ---: | ---: |
| DMD 2.113 debug | 0.49 s | 133940 KiB |
| LDC 1.43 release | 2.86 s | 263588 KiB |

Prepared static theme data reported by the consumer is 648 bytes for three
built-in `SelectionTheme` values plus one `SelectionCandidates` value.

Example runtime selections from that run:

```text
dark background  contrast=18.4245 deltaEOK=0.8238 rgb=(0.9577, 0.9760, 1.0000)
light background contrast=18.5527 deltaEOK=0.8808 rgb=(0.0013, 0.0067, 0.0208)
```

Runtime construction of 5,000 varying-hue Dark selection themes used the same
ordinary `makeSelectionTheme` function as the CTFE built-ins:

| build | runtime construction |
| --- | ---: |
| DMD 2.113 debug | 8681.24 ns/theme |
| LDC 1.43 release | 3390.66 ns/theme |

The benchmark checksum was finite and identical in both runs
(`2898.292725`).

These hosted-runner values are characterization evidence, not performance
guarantees or release gates.

## API friction

**No actionable color-d API friction was demonstrated.**

The consumer uses the root import surface and ordinary value operations. No
theme builder, palette wrapper, OSM role, renderer hook, allocation API or
application-specific convenience function is required from color-d.

The public root import and ordinary value API were sufficient. No provider-side
adapter or convenience layer was required.

One consumer-CI lesson was found: bare `dub test` activates provider
`version(unittest)` code in dependencies. Dunia therefore runs its own tests
with an explicit `--build=debug`, which still executes Dunia unittests while
building color-d as a normal external library. This is a DUB test-mode detail,
not a color-d API defect.

## Conclusion

The real editor consumer validates the intended architecture:

```text
static Dunia theme policy
       -> color-d math at CTFE
       -> prepared semantic candidates
       -> runtime background input
       -> Dunia-owned candidate selection
```

For this consumer path no color-d API correction is required before v0.1.
