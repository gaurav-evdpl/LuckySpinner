import SwiftUI

// MARK: - Piece model

/// A single confetti piece — its shape, colour, and flight path are pre-computed
/// so the view body is pure layout.
private struct ConfettiPiece: Identifiable {
    let id: Int
    let color: Color
    let isCircle: Bool
    /// Direction the piece flies, in radians (full 360° spread).
    let angle: Double
    /// How far the piece travels, as a fraction of the view's radius.
    let distance: CGFloat
    /// Size of the piece in points.
    let size: CGFloat
    /// Total spin during the burst, in degrees.
    let spin: Double
}

// MARK: - Confetti view

/// A dependency-free confetti burst. Pieces are **always in the view tree**
/// so SwiftUI can interpolate their properties. When `isActive` is `false` the
/// pieces are scaled to 0 (invisible with no layout footprint); when it
/// becomes `true` they burst outward from the centre, spin, and fade.
struct ConfettiView: View {

    /// Toggling this from `false` → `true` triggers the burst.
    let isActive: Bool

    /// Palette used to colour the pieces.
    var colors: [Color] = LuckySpinnerTheme.classic

    /// Number of pieces in the burst.
    var count: Int = 100

    /// How long the burst animation runs (seconds).
    var duration: Double = 1.6

    // MARK: Animation state

    /// 0 → pieces at centre (scale ≈ 0), 1 → fully spread and faded.
    @State private var phase: CGFloat = 0

    // MARK: Pieces (deterministic from index)

    private var pieces: [ConfettiPiece] {
        let palette = colors.isEmpty ? LuckySpinnerTheme.classic : colors
        return (0..<count).map { i in
            let baseAngle = (Double(i) / Double(count)) * 2 * .pi
            let jitter    = ((Double((i * 53) % 100) / 100.0) - 0.5) * 0.6
            let r = Double((i * 71 + 7) % 100) / 100.0   // 0…1
            let s = Double((i * 29 + 13) % 100) / 100.0  // 0…1
            return ConfettiPiece(
                id: i,
                color: palette[i % palette.count],
                isCircle: i % 2 == 0,
                angle: baseAngle + jitter,
                distance: CGFloat(0.50 + r * 0.45),       // 50–95 % of the radius
                size: CGFloat(10 + r * 12),               // 10–22 pt
                spin: 180 + s * 540
            )
        }
    }

    // MARK: Body

    var body: some View {
        GeometryReader { geo in
            ZStack {
                ForEach(pieces) { piece in
                    Group {
                        if piece.isCircle {
                            Circle().fill(piece.color)
                        } else {
                            RoundedRectangle(cornerRadius: 2).fill(piece.color)
                        }
                    }
                    .frame(width: piece.size, height: piece.size)
                    .rotationEffect(.degrees(phase * piece.spin))
                    .offset(flightOffset(for: piece, in: geo.size))
                    .opacity(1.0 - phase * 0.85)          // fade as they fly
                    .scaleEffect(max(0.001, phase))       // invisible at 0, full-size at 1
                    .position(x: geo.size.width / 2, y: geo.size.height / 2)
                }
            }
        }
        .allowsHitTesting(false)
        .drawingGroup()   // renders the ZStack into a single layer – smoother burst
        .onChange(of: isActive) { active in
            if active { triggerBurst() } else { phase = 0 }
        }
        .onAppear {
            if isActive { triggerBurst() }
        }
    }

    // MARK: Flight math

    /// Where the piece sits for the current `phase`.
    private func flightOffset(for piece: ConfettiPiece, in size: CGSize) -> CGSize {
        let radius = min(size.width, size.height) / 2
        let p = phase
        let x = cos(piece.angle) * piece.distance * radius * p
        // Fly outward + a gentle gravity drop at the end.
        let y = sin(piece.angle) * piece.distance * radius * p
              + 0.15 * radius * p * p
        return CGSize(width: x, height: y)
    }

    // MARK: Trigger

    /// Snap to the start, then animate 0 → 1 on the next runloop tick.
    /// Splitting the snap from the animation guarantees SwiftUI sees the
    /// transition, even when `isActive` was already `false`.
    private func triggerBurst() {
        phase = 0                         // snap – no animation
        DispatchQueue.main.async {
            withAnimation(.easeOut(duration: duration)) {
                phase = 1                 // animate outward
            }
        }
    }
}

// MARK: - Previews

#if DEBUG
struct ConfettiView_Previews: PreviewProvider {
    static var previews: some View {
        ConfettiView(isActive: true)
            .frame(width: 300, height: 300)
            .background(Color.black.opacity(0.05))
    }
}
#endif
