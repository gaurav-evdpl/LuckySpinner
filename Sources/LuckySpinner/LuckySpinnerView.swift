import SwiftUI

/// A SwiftUI spinner wheel that randomly selects one item from a list of names.
///
/// Pass in a list of names and tap the spin button. The wheel rotates with a
/// smooth animation, stops on a random person, displays the selected name, and
/// shows confetti behind the result.
///
/// ```swift
/// LuckySpinnerView(
///     names: ["Gaurav", "Rahul", "Priya", "Amit"],
///     title: "Who is lucky today?",
///     buttonTitle: "Spin",
///     onSelection: { selectedName in
///         print("Selected:", selectedName)
///     }
/// )
/// ```
public struct LuckySpinnerView: View {

    // MARK: Inputs

    private let names: [String]
    private let title: String
    private let buttonTitle: String
    private let config: LuckySpinnerConfig
    private let onSelection: (String) -> Void

    // MARK: State

    @State private var rotation: Double = 0
    @State private var isSpinning = false
    @State private var selectedName: String?
    @State private var showConfetti = false

    /// Creates a lucky spinner.
    ///
    /// - Parameters:
    ///   - names: The list of names to place on the wheel.
    ///   - title: The title shown above the wheel. Defaults to `"Lucky Spinner"`.
    ///   - buttonTitle: The label of the spin button. Defaults to `"Spin"`.
    ///   - config: Visual and behavioral configuration. Defaults to ``LuckySpinnerConfig/default``.
    ///   - onSelection: A closure called with the selected name once a spin finishes.
    public init(
        names: [String],
        title: String = "Lucky Spinner",
        buttonTitle: String = "Spin",
        config: LuckySpinnerConfig = .default,
        onSelection: @escaping (String) -> Void = { _ in }
    ) {
        self.names = names
        self.title = title
        self.buttonTitle = buttonTitle
        self.config = config
        self.onSelection = onSelection
    }

    public var body: some View {
        VStack(spacing: 20) {
            Text(title)
                .font(.title2.bold())
                .multilineTextAlignment(.center)

            if names.isEmpty {
                emptyState
            } else {
                wheelSection
                resultSection
                spinButton
            }
        }
        .padding()
    }

    // MARK: Sections

    /// Shown when no names were provided.
    private var emptyState: some View {
        VStack(spacing: 12) {
            Image(systemName: "exclamationmark.circle")
                .font(.largeTitle)
                .foregroundColor(.secondary)
            Text("No names provided")
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, minHeight: 200)
    }

    /// The wheel with the top pointer and confetti overlay.
    private var wheelSection: some View {
        ZStack {
            // Confetti sits behind the wheel content but in front of the background.
            if config.showsConfetti {
                ConfettiView(isActive: showConfetti, colors: config.colors)
                    .frame(width: config.wheelSize * 1.4, height: config.wheelSize * 1.4)
            }

            SpinnerWheelView(
                names: names,
                colors: config.colors,
                rotation: rotation,
                wheelSize: config.wheelSize
            )

            // A fixed pointer at the top, pointing down into the wheel.
            VStack {
                pointer
                Spacer()
            }
            .frame(height: config.wheelSize)
        }
        .frame(width: config.wheelSize * 1.4, height: config.wheelSize * 1.4)
    }

    /// The downward-pointing triangle at the top of the wheel.
    private var pointer: some View {
        Triangle()
            .fill(Color.red)
            .frame(width: 26, height: 22)
            .shadow(radius: 2)
            .offset(y: -4)
    }

    /// Shows the selected name (or a hint before the first spin).
    private var resultSection: some View {
        VStack(spacing: 4) {
            if let selectedName {
                Text(config.selectedText)
                    .font(.caption)
                    .foregroundColor(.secondary)
                Text(selectedName)
                    .font(.title.bold())
                    .foregroundColor(.primary)
                    .transition(.scale.combined(with: .opacity))
            } else {
                Text("Tap \(buttonTitle) to start")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
        .frame(minHeight: 60)
        .animation(.spring(), value: selectedName)
    }

    /// The spin button. Disabled while a spin is in progress or no names exist.
    private var spinButton: some View {
        Button(action: spin) {
            Text(isSpinning ? "Spinning…" : buttonTitle)
                .font(.headline)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(
                    RoundedRectangle(cornerRadius: config.buttonCornerRadius)
                        .fill(isSpinning ? Color.gray : Color.accentColor)
                )
        }
        .disabled(isSpinning || names.isEmpty)
        .padding(.horizontal)
    }

    // MARK: Spin logic

    /// Spins the wheel to a random name and reports the result.
    private func spin() {
        // Guard against empty names and double taps while spinning.
        guard !names.isEmpty, !isSpinning else { return }

        isSpinning = true
        showConfetti = false
        selectedName = nil

        let targetIndex = Int.random(in: 0..<names.count)
        let target = LuckySpinnerView.targetRotation(
            currentRotation: rotation,
            selectedIndex: targetIndex,
            count: names.count,
            extraSpins: config.extraSpins
        )

        withAnimation(.easeOut(duration: config.spinDuration)) {
            rotation = target
        }

        // After the animation finishes, reveal the result and confetti.
        DispatchQueue.main.asyncAfter(deadline: .now() + config.spinDuration) {
            selectedName = names[targetIndex]
            isSpinning = false
            if config.showsConfetti {
                showConfetti = true
            }
            onSelection(names[targetIndex])
        }
    }

    // MARK: Math helpers

    /// Calculates the absolute rotation (in degrees) needed to land the selected
    /// slice under the fixed top pointer.
    ///
    /// The slice at `selectedIndex` is centered at `anglePerItem * index + anglePerItem/2`
    /// degrees clockwise from the top. To bring that center to the top pointer (0°), the
    /// wheel must rotate by the negative of that angle, plus a whole number of extra spins.
    /// The result is normalized to always rotate forward from `currentRotation`.
    ///
    /// - Parameters:
    ///   - currentRotation: The wheel's current rotation, in degrees.
    ///   - selectedIndex: The index of the slice that should win.
    ///   - count: The total number of slices.
    ///   - extraSpins: The number of extra full rotations to add for effect.
    /// - Returns: The new absolute rotation value to animate to.
    static func targetRotation(
        currentRotation: Double,
        selectedIndex: Int,
        count: Int,
        extraSpins: Int
    ) -> Double {
        guard count > 0 else { return currentRotation }

        let anglePerItem = 360.0 / Double(count)
        let sliceCenter = anglePerItem * Double(selectedIndex) + anglePerItem / 2

        // The final orientation (mod 360) that places the slice under the pointer.
        let desiredMod = (360.0 - sliceCenter).truncatingRemainder(dividingBy: 360)

        // Base on current rotation so the wheel always continues forward.
        let currentMod = currentRotation.truncatingRemainder(dividingBy: 360)
        var delta = desiredMod - currentMod
        if delta < 0 { delta += 360 }

        return currentRotation + Double(extraSpins) * 360 + delta
    }
}

/// A simple downward-pointing triangle used as the wheel pointer.
private struct Triangle: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.midX, y: rect.maxY)) // bottom tip
        path.addLine(to: CGPoint(x: rect.minX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
        path.closeSubpath()
        return path
    }
}

#if DEBUG
struct LuckySpinnerView_Previews: PreviewProvider {
    static var previews: some View {
        LuckySpinnerView(
            names: ["Gaurav", "Rahul", "Priya", "Amit", "Neha"],
            title: "Team Spinner"
        )
        .padding()
        .previewDisplayName("Team Spinner")

        LuckySpinnerView(names: [], title: "No Names")
            .padding()
            .previewDisplayName("Empty")
    }
}
#endif
