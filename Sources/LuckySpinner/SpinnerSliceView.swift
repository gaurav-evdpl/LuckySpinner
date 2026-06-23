import SwiftUI

/// A pie-slice `Shape` that fills the wedge between two angles of a circle.
///
/// Angles are measured in degrees, clockwise from the top of the wheel.
/// This is an internal building block used by ``SpinnerWheelView``.
struct SpinnerSlice: Shape {

    /// The starting angle of the slice, in degrees.
    let startAngle: Double

    /// The ending angle of the slice, in degrees.
    let endAngle: Double

    func path(in rect: CGRect) -> Path {
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let radius = min(rect.width, rect.height) / 2

        var path = Path()
        path.move(to: center)
        path.addArc(
            center: center,
            radius: radius,
            // Subtract 90° so 0° points to the top of the wheel instead of the right.
            startAngle: .degrees(startAngle - 90),
            endAngle: .degrees(endAngle - 90),
            clockwise: false
        )
        path.closeSubpath()
        return path
    }
}

/// A single colored slice of the wheel with a name label.
///
/// This is an internal building block used by ``SpinnerWheelView``.
struct SpinnerSliceView: View {

    /// The name shown on this slice.
    let name: String

    /// The fill color of this slice.
    let color: Color

    /// The index of this slice (0-based).
    let index: Int

    /// The total number of slices on the wheel.
    let total: Int

    /// The overall size of the wheel, used to scale the label position.
    let wheelSize: CGFloat

    /// The angle each slice occupies, in degrees.
    private var anglePerItem: Double {
        360.0 / Double(total)
    }

    /// The angle at the center of this slice, in degrees.
    private var midAngle: Double {
        anglePerItem * Double(index) + anglePerItem / 2
    }

    var body: some View {
        ZStack {
            SpinnerSlice(
                startAngle: anglePerItem * Double(index),
                endAngle: anglePerItem * Double(index + 1)
            )
            .fill(color)
            .overlay(
                SpinnerSlice(
                    startAngle: anglePerItem * Double(index),
                    endAngle: anglePerItem * Double(index + 1)
                )
                .stroke(Color.white.opacity(0.6), lineWidth: 1)
            )

            // The name label, pushed out toward the rim and rotated to follow the slice.
            Text(name)
                .font(.system(size: max(11, wheelSize * 0.045), weight: .semibold))
                .foregroundColor(.white)
                .lineLimit(1)
                .minimumScaleFactor(0.5)
                .frame(maxWidth: wheelSize * 0.42)
                .rotationEffect(.degrees(midAngle))
                .offset(labelOffset)
        }
    }

    /// Positions the label roughly two-thirds of the way out along the slice's mid-angle.
    private var labelOffset: CGSize {
        let radius = wheelSize * 0.30
        let radians = (midAngle - 90) * .pi / 180
        return CGSize(
            width: cos(radians) * radius,
            height: sin(radians) * radius
        )
    }
}

#if DEBUG
struct SpinnerSliceView_Previews: PreviewProvider {
    static var previews: some View {
        SpinnerSliceView(
            name: "Gaurav",
            color: .blue,
            index: 0,
            total: 4,
            wheelSize: 300
        )
        .frame(width: 300, height: 300)
    }
}
#endif
