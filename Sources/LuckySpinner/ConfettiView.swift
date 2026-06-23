import SwiftUI

/// A single piece of confetti with a fixed color, shape, and travel path.
private struct ConfettiPiece: Identifiable {
    let id: Int
    let color: Color
    let isCircle: Bool
    let startX: CGFloat       // horizontal start, as a fraction of width (-0.5...0.5)
    let endX: CGFloat         // horizontal end, as a fraction of width
    let endY: CGFloat         // vertical end, as a fraction of height (downward)
    let size: CGFloat
    let rotation: Double
    let delay: Double
}

/// A lightweight, dependency-free confetti burst built entirely in SwiftUI.
///
/// The confetti animates outward and downward from the center whenever `isActive`
/// becomes `true`. It uses only simple shapes and works in SwiftUI previews.
///
/// This is an internal building block used by ``LuckySpinnerView``.
struct ConfettiView: View {

    /// When `true`, the confetti plays its burst animation.
    let isActive: Bool

    /// The colors to draw the confetti pieces from.
    var colors: [Color] = LuckySpinnerTheme.classic

    /// How many pieces to show.
    var count: Int = 40

    @State private var animate = false

    /// Pre-computed pieces. Positions are derived from the index so the layout is
    /// stable and reproducible (also keeping previews and tests deterministic).
    private var pieces: [ConfettiPiece] {
        let palette = colors.isEmpty ? LuckySpinnerTheme.classic : colors
        return (0..<count).map { i in
            // A simple pseudo-random spread based on the index. No global RNG needed.
            let a = Double((i * 53) % 100) / 100.0       // 0...1
            let b = Double((i * 29 + 13) % 100) / 100.0  // 0...1
            let c = Double((i * 71 + 7) % 100) / 100.0   // 0...1
            return ConfettiPiece(
                id: i,
                color: palette[i % palette.count],
                isCircle: i % 2 == 0,
                startX: CGFloat(a - 0.5) * 0.2,
                endX: CGFloat(a - 0.5) * 1.6,
                endY: CGFloat(0.4 + b * 0.7),
                size: CGFloat(6 + c * 8),
                rotation: 180 + c * 540,
                delay: a * 0.15
            )
        }
    }

    var body: some View {
        GeometryReader { geo in
            ZStack {
                ForEach(pieces) { piece in
                    Group {
                        if piece.isCircle {
                            Circle()
                                .fill(piece.color)
                                .frame(width: piece.size, height: piece.size)
                        } else {
                            Rectangle()
                                .fill(piece.color)
                                .frame(width: piece.size, height: piece.size * 0.6)
                        }
                    }
                    .rotationEffect(.degrees(animate ? piece.rotation : 0))
                    .position(
                        x: geo.size.width / 2 + piece.startX * geo.size.width,
                        y: geo.size.height / 2
                    )
                    .offset(
                        x: animate ? piece.endX * geo.size.width : 0,
                        y: animate ? piece.endY * geo.size.height : 0
                    )
                    .opacity(animate ? 0 : 1)
                    .animation(
                        .easeOut(duration: 1.2).delay(piece.delay),
                        value: animate
                    )
                }
            }
        }
        .allowsHitTesting(false)
        .onAppear { restartIfNeeded() }
        .onChange(of: isActive) { _ in restartIfNeeded() }
    }

    /// Plays the burst from the start whenever it becomes active.
    private func restartIfNeeded() {
        guard isActive else {
            animate = false
            return
        }
        // Reset to the start, then animate outward on the next runloop tick.
        animate = false
        DispatchQueue.main.async {
            animate = true
        }
    }
}

#if DEBUG
struct ConfettiView_Previews: PreviewProvider {
    static var previews: some View {
        ConfettiView(isActive: true)
            .frame(width: 300, height: 300)
            .background(Color.black.opacity(0.05))
    }
}
#endif
