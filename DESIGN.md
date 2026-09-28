# Dunia Design

## Responsibility

Dunia is an application, not a reusable foundation library.

Dunia owns:

- editor semantic roles and interaction policy;
- theme/style policy;
- OSM editing workflows;
- map-background adaptation strategy;
- GUI composition and toolkit adapters;
- renderer policy;
- application configuration;
- cross-library orchestration.

Reusable mathematics and data mechanics remain in their domain libraries.

## First slice boundary

The first slice exercises `color-d` through editor-owned theme semantics.

```text
editor semantic seed/policy
        |
        v
color-d value mathematics
        |
        v
prepared editor render candidates
        |
        +---- fixed built-ins: CTFE
        |
        +---- user accent: runtime
        |
        v
consumer-owned background-dependent selection
```

`color-d` must not acquire Dunia theme roles, OSM tags, renderer policy or
background sampling rules.

Dunia must not duplicate general color conversion, gamut mapping, contrast or
perceptual-difference mathematics.
