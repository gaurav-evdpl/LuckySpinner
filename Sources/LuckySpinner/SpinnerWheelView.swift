import SwiftUI

/// The circular wheel made up of colored slices, one per name.
///
/// The wheel rotates by `rotation` degrees. A fixed pointer at the top of
/// ``LuckySpinnerView`` indicates which slice has been selected.
///
/// This is an internal building block used by ``LuckySpinnerView``.
struct SpinnerWheelView: View {

    /// The names to display around the wheel.
    let names: [String]

    /// The colors used to fill the slices (repeats if there are more names than colors).
    let colors: [Color]

    /// The current rotation of the wheel, in degrees.
    let rotation: Double

    /// The diameter of the wheel, in points.
    let wheelSize: CGFloat

    var body: some View {
        ZStack {
            // Each colored, labeled slice.
            ForEach(Array(names.enumerated()), id: \.offset) { index, name in
                SpinnerSliceView(
                    name: name,
                    color: color(for: index),
                    index: index,
                    total: names.count,
                    wheelSize: wheelSize
                )
            }

            // A thin rim around the wheel.
            Circle()
                .stroke(Color.primary.opacity(0.15), lineWidth: 4)

            // A small hub in the center.
            Circle()
                .fill(Color.white)
                .frame(width: wheelSize * 0.12, height: wheelSize * 0.12)
                .overlay(Circle().stroke(Color.primary.opacity(0.2), lineWidth: 2))
                .shadow(radius: 2)
        }
        .frame(width: wheelSize, height: wheelSize)
        .rotationEffect(.degrees(rotation))
    }

    /// Returns the slice color for a given index, wrapping around if needed.
    private func color(for index: Int) -> Color {
        guard !colors.isEmpty else { return .gray }
        return colors[index % colors.count]
    }
}

#if DEBUG
struct SpinnerWheelView_Previews: PreviewProvider {
    static var previews: some View {
        SpinnerWheelView(
            names: ["Gaurav", "Rahul", "Priya", "Amit", "Neha"],
            colors: LuckySpinnerTheme.classic,
            rotation: 0,
            wheelSize: 300
        )
        .padding()
    }
}
#endif
