module app;

import std.stdio :
    writefln,
    writeln;

import color :
    SRgbf;

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

    writeln(
        "Dunia color-d consumer correctness: PASS"
    );
}
