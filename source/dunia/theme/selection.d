module dunia.theme.selection;

import color;


/++
    Editor-owned theme mode for the first selection/accent consumer slice.

    This type is application policy. It deliberately does not belong in
    color-d.
+/
enum ThemeMode : ubyte
{
    light,
    dark,
    highContrast
}


/++
    One fully prepared renderer-facing color token.

    Both encoded and linear-light forms are retained because GUI/rendering
    consumers may need different representations. Oklab is retained only for
    consumer-side perceptual validation/selection.

    The representation is application-owned; color-d remains unaware of it.
+/
struct PreparedColor
{
    SRgbf encoded;
    LinearSRgbf linear;
    Oklabf perceptual;
}


/++
    First real Dunia selection/accent semantic family.
+/
struct SelectionTheme
{
    PreparedColor normal;
    PreparedColor hover;
    PreparedColor pressed;
    PreparedColor disabled;

    SRgbf surface;

    float minimumActiveContrast;
    float minimumDisabledContrast;
    float minimumStateDeltaE;
}


/++
    Precomputed candidates used by the runtime map-background selection layer.
+/
struct SelectionCandidates
{
    PreparedColor light;
    PreparedColor dark;
    PreparedColor highContrastLight;
    PreparedColor highContrastDark;
}


/++
    Runtime result of selecting a prepared candidate for one encoded-sRGB
    background sample.
+/
struct CandidateSelection
{
    bool valid;
    PreparedColor color;
    float contrast;
    float deltaE;
}


private PreparedColor prepareColor(
    Oklchf value
)
@safe
pure
nothrow
@nogc
{
    const linear =
        value.gamutMapRayTraceToLinearSRgb;

    const encoded =
        linear.toSRgb;

    const perceptual =
        linear
        .toXyzD65
        .toOklab;

    return PreparedColor(
        encoded,
        linear,
        perceptual
    );
}


private Oklabf encodedToOklab(
    SRgbf value
)
@safe
pure
nothrow
@nogc
{
    return
        value
        .toLinear
        .toXyzD65
        .toOklab;
}


private bool preparedColorValid(
    PreparedColor value
)
@safe
pure
nothrow
@nogc
{
    return
        value.linear.inGamut
        && value.encoded.inGamut;
}


private bool contrastAtLeast(
    SRgbf foreground,
    SRgbf background,
    float minimum
)
@safe
pure
nothrow
@nogc
{
    const measured =
        foreground.wcag2ContrastRatio(
            background
        );

    return
        measured.valid
        && measured.value >= minimum;
}


/++
    Builds one complete selection/accent family from a caller-supplied OKLCH
    seed.

    The caller owns all semantic policy. color-d supplies only ordinary color
    values, tone construction, gamut mapping and measurements.

    The function is intentionally usable both at CTFE and at runtime.
+/
SelectionTheme makeSelectionTheme(
    Oklchf seed,
    ThemeMode mode
)
@safe
pure
nothrow
@nogc
{
    float[4] lightnesses;
    float[4] chromas;

    SRgbf surface;

    float minimumActiveContrast;
    float minimumDisabledContrast;

    final switch (mode)
    {
        case ThemeMode.light:
        {
            lightnesses =
                [0.46f, 0.40f, 0.34f, 0.70f];

            chromas =
                [0.18f, 0.19f, 0.19f, 0.06f];

            surface =
                SRgbf(
                    0.96f,
                    0.96f,
                    0.97f
                );

            minimumActiveContrast = 3.0f;
            minimumDisabledContrast = 1.3f;

            break;
        }

        case ThemeMode.dark:
        {
            lightnesses =
                [0.74f, 0.82f, 0.66f, 0.46f];

            chromas =
                [0.16f, 0.17f, 0.17f, 0.05f];

            surface =
                SRgbf(
                    0.08f,
                    0.09f,
                    0.11f
                );

            minimumActiveContrast = 3.0f;
            minimumDisabledContrast = 1.3f;

            break;
        }

        case ThemeMode.highContrast:
        {
            lightnesses =
                [0.90f, 0.97f, 0.80f, 0.58f];

            chromas =
                [0.13f, 0.10f, 0.15f, 0.04f];

            surface =
                SRgbf(
                    0.0f,
                    0.0f,
                    0.0f
                );

            minimumActiveContrast = 4.5f;
            minimumDisabledContrast = 2.0f;

            break;
        }
    }


    Oklchf[4] tones;

    tonesAtLightnessAndChromaInto(
        seed,
        lightnesses,
        chromas,
        tones
    );


    return SelectionTheme(
        prepareColor(tones[0]),
        prepareColor(tones[1]),
        prepareColor(tones[2]),
        prepareColor(tones[3]),
        surface,
        minimumActiveContrast,
        minimumDisabledContrast,
        0.02f
    );
}


/++
    Validates Dunia's current selection/accent policy.

    The numerical operations come from color-d. Thresholds and the fact that
    these states are compared at all are application policy.
+/
bool validateSelectionTheme(
    SelectionTheme theme
)
@safe
pure
nothrow
@nogc
{
    if (
        !preparedColorValid(theme.normal)
        || !preparedColorValid(theme.hover)
        || !preparedColorValid(theme.pressed)
        || !preparedColorValid(theme.disabled)
    )
    {
        return false;
    }


    if (
        !contrastAtLeast(
            theme.normal.encoded,
            theme.surface,
            theme.minimumActiveContrast
        )
        || !contrastAtLeast(
            theme.hover.encoded,
            theme.surface,
            theme.minimumActiveContrast
        )
        || !contrastAtLeast(
            theme.pressed.encoded,
            theme.surface,
            theme.minimumActiveContrast
        )
        || !contrastAtLeast(
            theme.disabled.encoded,
            theme.surface,
            theme.minimumDisabledContrast
        )
    )
    {
        return false;
    }


    if (
        deltaEOK(
            theme.normal.perceptual,
            theme.hover.perceptual
        ) < theme.minimumStateDeltaE
        || deltaEOK(
            theme.normal.perceptual,
            theme.pressed.perceptual
        ) < theme.minimumStateDeltaE
        || deltaEOK(
            theme.hover.perceptual,
            theme.pressed.perceptual
        ) < theme.minimumStateDeltaE
    )
    {
        return false;
    }


    return true;
}


/++
    Builds the bounded set of semantic selection candidates that the renderer
    may choose between at runtime.

    No background information is consumed here, so this function remains
    usable at CTFE.
+/
SelectionCandidates makeSelectionCandidates(
    Oklchf seed
)
@safe
pure
nothrow
@nogc
{
    return SelectionCandidates(
        prepareColor(
            seed
            .withLightness(0.90f)
            .withChroma(0.10f)
        ),

        prepareColor(
            seed
            .withLightness(0.24f)
            .withChroma(0.10f)
        ),

        prepareColor(
            seed
            .withLightness(0.98f)
            .withChroma(0.02f)
        ),

        prepareColor(
            seed
            .withLightness(0.08f)
            .withChroma(0.02f)
        )
    );
}


private CandidateSelection evaluateCandidate(
    PreparedColor candidate,
    SRgbf background,
    Oklabf backgroundPerceptual
)
@safe
pure
nothrow
@nogc
{
    const contrast =
        candidate.encoded.wcag2ContrastRatio(
            background
        );

    if (!contrast.valid)
    {
        return CandidateSelection.init;
    }


    return CandidateSelection(
        true,
        candidate,
        contrast.value,
        deltaEOK(
            candidate.perceptual,
            backgroundPerceptual
        )
    );
}


private bool candidateIsBetter(
    CandidateSelection candidate,
    CandidateSelection current
)
@safe
pure
nothrow
@nogc
{
    if (!candidate.valid)
        return false;

    if (!current.valid)
        return true;


    enum float contrastTieWindow =
        0.05f;

    const float difference =
        candidate.contrast
        - current.contrast;

    if (difference > contrastTieWindow)
        return true;

    if (difference < -contrastTieWindow)
        return false;


    return candidate.deltaE > current.deltaE;
}


/++
    Chooses among already prepared selection candidates for one runtime
    encoded-sRGB background sample.

    WCAG contrast is the primary consumer policy. Perceptual separation is only
    used as a tie-breaker inside a small application-selected contrast window.

    Invalid/out-of-domain background input returns CandidateSelection.init.
+/
CandidateSelection chooseSelectionCandidate(
    SelectionCandidates candidates,
    SRgbf background
)
@safe
pure
nothrow
@nogc
{
    const backgroundLuminance =
        background.wcag2RelativeLuminance;

    if (!backgroundLuminance.valid)
        return CandidateSelection.init;


    const backgroundPerceptual =
        encodedToOklab(
            background
        );


    CandidateSelection best;


    const light =
        evaluateCandidate(
            candidates.light,
            background,
            backgroundPerceptual
        );

    if (candidateIsBetter(light, best))
        best = light;


    const dark =
        evaluateCandidate(
            candidates.dark,
            background,
            backgroundPerceptual
        );

    if (candidateIsBetter(dark, best))
        best = dark;


    const highContrastLight =
        evaluateCandidate(
            candidates.highContrastLight,
            background,
            backgroundPerceptual
        );

    if (
        candidateIsBetter(
            highContrastLight,
            best
        )
    )
    {
        best = highContrastLight;
    }


    const highContrastDark =
        evaluateCandidate(
            candidates.highContrastDark,
            background,
            backgroundPerceptual
        );

    if (
        candidateIsBetter(
            highContrastDark,
            best
        )
    {
        best = highContrastDark;
    }


    return best;
}


private bool scalarClose(
    float lhs,
    float rhs,
    float tolerance
)
@safe
pure
nothrow
@nogc
{
    const difference =
        lhs > rhs
            ? lhs - rhs
            : rhs - lhs;

    return difference <= tolerance;
}


/++
    Consumer-side CTFE/runtime agreement check for the final encoded tokens.

    This is an application regression tolerance, not a new color-d numerical
    contract.
+/
bool selectionThemesClose(
    SelectionTheme lhs,
    SelectionTheme rhs,
    float tolerance = 256.0f * float.epsilon
)
@safe
pure
nothrow
@nogc
{
    static bool colorClose(
        PreparedColor a,
        PreparedColor b,
        float tolerance
    )
    @safe
    pure
    nothrow
    @nogc
    {
        return
            scalarClose(
                a.encoded.r,
                b.encoded.r,
                tolerance
            )
            && scalarClose(
                a.encoded.g,
                b.encoded.g,
                tolerance
            )
            && scalarClose(
                a.encoded.b,
                b.encoded.b,
                tolerance
            );
    }


    return
        colorClose(
            lhs.normal,
            rhs.normal,
            tolerance
        )
        && colorClose(
            lhs.hover,
            rhs.hover,
            tolerance
        )
        && colorClose(
            lhs.pressed,
            rhs.pressed,
            tolerance
        )
        && colorClose(
            lhs.disabled,
            rhs.disabled,
            tolerance
        );
}


/++
    Creates an intentionally invalid consumer fixture whose normal selection
    token is identical to the theme surface.
+/
SelectionTheme makeInsufficientContrastFixture(
    SelectionTheme validTheme
)
@safe
pure
nothrow
@nogc
{
    const linear =
        validTheme.surface.toLinear;

    validTheme.normal =
        PreparedColor(
            validTheme.surface,
            linear,
            linear
                .toXyzD65
                .toOklab
        );

    return validTheme;
}


/++
    Converts an encoded user accent into the ordinary OKLCH seed consumed by
    makeSelectionTheme.
+/
Oklchf userAccentSeed(
    SRgbf encoded
)
@safe
pure
nothrow
@nogc
{
    return
        encoded
        .toLinear
        .toXyzD65
        .toOklab
        .toOklch;
}


/*
 * Fixed built-in themes are constructed by the ordinary runtime-capable
 * function during CTFE.
 */
enum builtInSeed =
    Oklchf(
        0.62f,
        0.20f,
        OklabHuef.fromDegrees(
            255.0f
        )
    );

enum builtInLightCtfe =
    makeSelectionTheme(
        builtInSeed,
        ThemeMode.light
    );

enum builtInDarkCtfe =
    makeSelectionTheme(
        builtInSeed,
        ThemeMode.dark
    );

enum builtInHighContrastCtfe =
    makeSelectionTheme(
        builtInSeed,
        ThemeMode.highContrast
    );

enum builtInCandidatesCtfe =
    makeSelectionCandidates(
        builtInSeed
    );


static assert(
    validateSelectionTheme(
        builtInLightCtfe
    )
);

static assert(
    validateSelectionTheme(
        builtInDarkCtfe
    )
);

static assert(
    validateSelectionTheme(
        builtInHighContrastCtfe
    )
);


immutable SelectionTheme builtInLightTheme =
    builtInLightCtfe;

immutable SelectionTheme builtInDarkTheme =
    builtInDarkCtfe;

immutable SelectionTheme builtInHighContrastTheme =
    builtInHighContrastCtfe;

immutable SelectionCandidates builtInSelectionCandidates =
    builtInCandidatesCtfe;


/*
 * Explicitly prove that a vivid application seed can lie outside linear sRGB
 * before the consumer-selected gamut policy is applied.
 */
enum vividOutOfGamutSeed =
    Oklchf(
        0.65f,
        0.45f,
        OklabHuef.fromDegrees(
            35.0f
        )
    );

enum vividRawLinear =
    vividOutOfGamutSeed
    .toOklab
    .toXyzD65
    .toLinearSRgb;

static assert(
    !vividRawLinear.inGamut
);

enum vividMappedLinear =
    vividOutOfGamutSeed
    .gamutMapRayTraceToLinearSRgb;

static assert(
    vividMappedLinear.inGamut
);


@safe
pure
nothrow
@nogc
unittest
{
    const runtimeLight =
        makeSelectionTheme(
            builtInSeed,
            ThemeMode.light
        );

    assert(
        selectionThemesClose(
            runtimeLight,
            builtInLightCtfe
        )
    );


    const invalid =
        makeInsufficientContrastFixture(
            runtimeLight
        );

    assert(
        !validateSelectionTheme(
            invalid
        )
    );


    const darkBackground =
        SRgbf(
            0.04f,
            0.05f,
            0.06f
        );

    const lightBackground =
        SRgbf(
            0.94f,
            0.95f,
            0.96f
        );


    const onDark =
        chooseSelectionCandidate(
            builtInCandidatesCtfe,
            darkBackground
        );

    const onLight =
        chooseSelectionCandidate(
            builtInCandidatesCtfe,
            lightBackground
        );

    assert(onDark.valid);
    assert(onLight.valid);

    assert(
        onDark.color.encoded
        != onLight.color.encoded
    );
}
