import SwiftUI

/// A single piece of confetti with a fixed color, shape, and travel direction.
private struct ConfettiPiece: Identifiable {
    let id: Int
    let color: Color
    let isCircle: Bool
    let angle: Double         // direction to fly, in radians (full 360° spread)
    let distance: CGFloat     // how far to fly, as a fraction of the view size
    let drop: CGFloat         // extra downward gravity at the end, as a fraction
    let size: CGFloat
    let spin: Double          // total degrees of rotation during the burst
    let delay: Double         // small stagger so pieces don't move in lockstep
}

/// A lightweight, dependency-free confetti burst built entirely in SwiftUI.
///
/// The view shows **nothing** until `isActive` becomes `true`. At that moment the
/// pieces appear at the center and burst outward in all directions, then fade.
/// It uses only simple shapes — no third-party libraries.
///
/// This is an internal building block used by ``LuckySpinnerView``.
struct ConfettiView: View {

    /// When `true`, the confetti plays its burst animation. While `false`,
    /// nothing is drawn at all.
    let isActive: Bool

    /// The colors to draw the confetti pieces from.
    var colors: [Color] = LuckySpinnerTheme.classic

    /// How many pieces to show.
    var count: Int = 40

    /// How long the burst takes to fly out and fade, in seconds.
    var duration: Double = 1.6

    /// Drives the whole burst. `0` = pieces stacked at center (invisible start),
    /// `1` = pieces fully spread out and faded. A single animated value keeps the
    /// animation reliable: SwiftUI always interpolates 0 -> 1.
    @State private var progress: CGFloat = 0

    /// Pre-computed pieces. Directions are spread evenly around a full circle and
    /// derived from the index, so the layout is stable (and previews/tests stay
    /// deterministic) while still looking scattered.
    private var pieces: [ConfettiPiece] {
        let palette = colors.isEmpty ? LuckySpinnerTheme.classic : colors
        return (0..<count).map { i in
            // Spread directions evenly around the circle, with a per-piece jitter.
            let baseAngle = (Double(i) / Double(count)) * 2 * .pi
            let jitter = (Double((i * 53) % 100) / 100.0 - 0.5) * 0.5
            let r = Double((i * 71 + 7) % 100) / 100.0   // 0...1
            let s = Double((i * 29 + 13) % 100) / 100.0  // 0...1
            return ConfettiPiece(
                id: i,
                color: palette[i % palette.count],
                isCircle: i % 2 == 0,
                angle: baseAngle + jitter,
                distance: CGFloat(0.45 + r * 0.35),   // fly 45–80% of the radius
                drop: CGFloat(0.10 + s * 0.20),       // a little gravity at the end
                size: CGFloat(7 + r * 7),             // 7–14 pt
                spin: 180 + s * 540,
                delay: r * 0.12
            )
        }
    }

    var body: some View {
        GeometryReader { geo in
            // Draw nothing at all until the burst is active.
            if isActive {
                ZStack {
                    ForEach(pieces) { piece in
                        shape(for: piece)
                            .frame(width: piece.size, height: piece.size)
                            .rotationEffect(.degrees(Double(progress) * piece.spin))
                            .offset(offset(for: piece, in: geo.size))
                            // Fade in fast, then fade out as the piece reaches the end.
                            .opacity(opacity(at: progress))
                            .position(x: geo.size.width / 2, y: geo.size.height / 2)
                    }
                }
            }
        }
        .allowsHitTesting(false)
        // Start the burst the moment the view becomes active.
        .onChange(of: isActive) { active in
            if active { fire() }
        }
        // Also handle the case where the view appears already-active.
        .onAppear {
            if isActive { fire() }
        }
    }

    // MARK: Drawing

    @ViewBuilder
    private func shape(for piece: ConfettiPiece) -> some View {
        if piece.isCircle {
            Circle().fill(piece.color)
        } else {
            RoundedRectangle(cornerRadius: 1).fill(piece.color)
        }
    }

    /// The current position offset of a piece for the given progress.
    private func offset(for piece: ConfettiPiece, in size: CGSize) -> CGSize {
        let reach = min(size.width, size.height) / 2
        let x = cos(piece.angle) * piece.distance * reach * progress
        // Vertical travel plus a bit of extra downward "gravity" as it falls.
        let y = sin(piece.angle) * piece.distance * reach * progress
              + piece.drop * reach * progress * progress
        return CGSize(width: x, height: y)
    }

    /// Pieces pop in instantly, hold, then fade out near the end of the burst.
    private func opacity(at p: CGFloat) -> Double {
        if p < 0.05 { return Double(p / 0.05) }   // quick fade-in
        if p > 0.75 { return Double((1 - p) / 0.25) } // fade-out
        return 1
    }

    // MARK: Trigger

    /// Resets to the center, then animates a single 0 -> 1 burst.
    private func fire() {
        // Snap back to the start with no animation.
        var reset = Transaction()
        reset.disablesAnimations = true
        withTransaction(reset) {
            progress = 0
        }
        // Animate outward on the next runloop tick so the 0 -> 1 change is observed.
        DispatchQueue.main.async {
            withAnimation(.easeOut(duration: duration)) {
                progress = 1
            }
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
