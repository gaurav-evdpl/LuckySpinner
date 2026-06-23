import SwiftUI

/// A small collection of ready-to-use color palettes for the spinner wheel.
///
/// Use these as a convenient starting point for `LuckySpinnerConfig.colors`,
/// or pass your own array of `Color` values instead.
///
/// ```swift
/// var config = LuckySpinnerConfig.default
/// config.colors = LuckySpinnerTheme.pastel
/// ```
public enum LuckySpinnerTheme {

    /// A bright, playful palette. This is also the default wheel palette.
    public static let classic: [Color] = [
        .red, .orange, .yellow, .green, .blue, .purple, .pink, .teal
    ]

    /// Softer, lighter colors that work well on light backgrounds.
    public static let pastel: [Color] = [
        Color(red: 0.98, green: 0.80, blue: 0.80),
        Color(red: 0.80, green: 0.90, blue: 0.98),
        Color(red: 0.82, green: 0.96, blue: 0.82),
        Color(red: 0.99, green: 0.93, blue: 0.78),
        Color(red: 0.92, green: 0.82, blue: 0.98),
        Color(red: 0.80, green: 0.96, blue: 0.94)
    ]

    /// A cool, ocean-inspired palette of blues and greens.
    public static let ocean: [Color] = [
        Color(red: 0.05, green: 0.30, blue: 0.55),
        Color(red: 0.10, green: 0.45, blue: 0.70),
        Color(red: 0.15, green: 0.60, blue: 0.75),
        Color(red: 0.20, green: 0.70, blue: 0.70),
        Color(red: 0.25, green: 0.55, blue: 0.60)
    ]
}
