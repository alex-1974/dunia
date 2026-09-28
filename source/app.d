module app;

import std.datetime.stopwatch :
    AutoStart,
    StopWatch;

import std.stdio :
    writefln,
    writeln;

import color :
    OklabHuef,
    SRgbf,
    withHue;

import dunia.theme.selection :
    CandidateSelection,
    SelectionCandidates,
    SelectionTheme,
    ThemeMode,
    builtInDarkTheme,
    builtInHighContrastTheme,
    builtInLightTheme,
    builtInSelectionCandidates,
    builtInSeed,
    chooseSelectionCandidate,
    makeInsufficientContrastFixture,
    makeSelectionTheme,
    selectionThemesClose,
    userAccentSeed,
    validateSelectionTheme;


private void require(
    bool condition,
    string message
)
{
    if (!condition)
        throw new Exception(message);
}


private void reportCandidate(
    string label,
    CandidateSelection selection
)
{
    require(
        selection.valid,
        label ~ " candidate selection failed"
    );

    writefln(
        "%s contrast=%.4f deltaEOK=%.4f rgb=(%.4f, %.4f, %.4f)",
        label,
        selection.contrast,
        selection.deltaE,
        selection.color.encoded.r,
        selection.color.encoded.g,
        selection.color.encoded.b
    );
}



private void benchmarkRuntimeThemeConstruction()
{
    enum size_t iterations = 5_000;

    float checksum;

    auto stopwatch =
        StopWatch(
            AutoStart.yes
        );

    foreach (i; 0 .. iterations)
    {
        const seed =
            builtInSeed.withHue(
                OklabHuef.fromDegrees(
                    cast(float)(i % 360)
                )
            );

        const theme =
            makeSelectionTheme(
                seed,
                ThemeMode.dark
            );

        checksum +=
            theme.normal.encoded.r;
    }

    stopwatch.stop();

    const long elapsedNs =
        stopwatch
        .peek
        .total!"nsecs";

    writefln(
        "runtime_theme_build_ns_per_theme=%.2f benchmark_checksum=%.6f",
        cast(double)elapsedNs
            / cast(double)iterations,
        checksum
    );
}


void main()
{
    writeln(
        "Dunia color-d theme consumer"
    );


    require(
        validateSelectionTheme(
            builtInLightTheme
        ),
        "built-in light theme failed validation"
    );

    require(
        validateSelectionTheme(
            builtInDarkTheme
        ),
        "built-in dark theme failed validation"
    );

    require(
        validateSelectionTheme(
            builtInHighContrastTheme
        ),
        "built-in high-contrast theme failed validation"
    );


    const runtimeEquivalent =
        makeSelectionTheme(
            builtInSeed,
            ThemeMode.light
        );

    require(
        selectionThemesClose(
            runtimeEquivalent,
            builtInLightTheme
        ),
        "runtime and CTFE theme construction diverged"
    );


    const invalid =
        makeInsufficientContrastFixture(
            runtimeEquivalent
        );

    require(
        !validateSelectionTheme(
            invalid
        ),
        "insufficient-contrast fixture was not rejected"
    );


    const userSeed =
        userAccentSeed(
            SRgbf(
                0.90f,
                0.20f,
                0.12f
            )
        );

    const userDarkTheme =
        makeSelectionTheme(
            userSeed,
            ThemeMode.dark
        );

    require(
        validateSelectionTheme(
            userDarkTheme
        ),
        "runtime user-accent theme failed validation"
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
            builtInSelectionCandidates,
            darkBackground
        );

    const onLight =
        chooseSelectionCandidate(
            builtInSelectionCandidates,
            lightBackground
        );


    reportCandidate(
        "dark background",
        onDark
    );

    reportCandidate(
        "light background",
        onLight
    );


    require(
        onDark.color.encoded
        != onLight.color.encoded,
        "runtime background cases selected the same candidate"
    );


    writefln(
        "prepared_static_theme_bytes=%s",
        3 * SelectionTheme.sizeof
        + SelectionCandidates.sizeof
    );

    benchmarkRuntimeThemeConstruction();

    writeln(
        "Dunia color-d consumer correctness: PASS"
    );
}
