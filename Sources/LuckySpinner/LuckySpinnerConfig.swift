import SwiftUI

/// Configuration options that control how a ``LuckySpinnerView`` looks and behaves.
///
/// Create a value with the memberwise initializer and tweak only what you need,
/// or start from ``LuckySpinnerConfig/default`` and override individual properties.
///
/// ```swift
/// let config = LuckySpinnerConfig(
///     wheelSize: 320,
///     spinDuration: 3,
///     extraSpins: 6,
///     showsConfetti: true,
///     buttonCornerRadius: 16,
///     selectedText: "Selected",
///     colors: [.red, .blue, .green, .orange, .purple]
/// )
/// ```
public struct LuckySpinnerConfig {

    /// The width and height of the circular wheel, in points.
    public var wheelSize: CGFloat

    /// How long the spin animation runs, in seconds.
    public var spinDuration: Double

    /// The number of extra full rotations the wheel makes before stopping.
    ///
    /// A higher value makes the spin feel longer and more dramatic.
    public var extraSpins: Int

    /// Whether confetti is shown after a name is selected.
    public var showsConfetti: Bool

    /// The corner radius of the spin button.
    public var buttonCornerRadius: CGFloat

    /// The label shown above the selected name (for example `"Selected"`).
    public var selectedText: String

    /// The colors used for the wheel slices.
    ///
    /// Colors repeat if there are more names than colors.
    public var colors: [Color]

    /// Creates a new configuration.
    ///
    /// - Parameters:
    ///   - wheelSize: The width and height of the wheel, in points. Defaults to `300`.
    ///   - spinDuration: How long the spin animation runs, in seconds. Defaults to `3`.
    ///   - extraSpins: Extra full rotations before stopping. Defaults to `5`.
    ///   - showsConfetti: Whether confetti is shown after selection. Defaults to `true`.
    ///   - buttonCornerRadius: The corner radius of the spin button. Defaults to `14`.
    ///   - selectedText: The label shown above the selected name. Defaults to `"Selected"`.
    ///   - colors: The colors used for the wheel slices. Defaults to ``LuckySpinnerTheme/classic``.
    public init(
        wheelSize: CGFloat = 300,
        spinDuration: Double = 3,
        extraSpins: Int = 5,
        showsConfetti: Bool = true,
        buttonCornerRadius: CGFloat = 14,
        selectedText: String = "Selected",
        colors: [Color] = LuckySpinnerTheme.classic
    ) {
        self.wheelSize = wheelSize
        self.spinDuration = spinDuration
        self.extraSpins = extraSpins
        self.showsConfetti = showsConfetti
        self.buttonCornerRadius = buttonCornerRadius
        self.selectedText = selectedText
        self.colors = colors
    }

    /// A sensible, beginner-friendly default configuration.
    public static let `default` = LuckySpinnerConfig()
}
